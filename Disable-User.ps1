##################################################################
#                 << Desativação de usuários >>                  #
#                                                                #
# 1 - Desativa conta no AD                                       #
# 2 - Desativa conta no Lync                                     #
# 3 - Habilita mensagem de ausencia temporaria(OOF) no Exchange  #
#                                                                #
# Coded by Robson Reis Bispo                                     #
# Last update - 06/2015                                          #
##################################################################

# Define parametros requeridos
param(
[Parameter(Position=0,Mandatory=$true)]
[string]$username,
[Parameter(Position=1)]
[string]$oofmsg
)

$ErrorActionPreference = "Stop"

# Importação dos modulos
$ExSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://morpheus.sp01.local/PowerShell/ -AllowRedirection -Authentication Kerberos
[void](Import-PSSession $ExSession)
Import-Module ActiveDirectory
Import-Module Lync


# Definição variaveis gerais
$GC = 'sp01.local:3268'
$ADUser = Get-ADUser -Filter {(samAccountName -eq $username)} -properties canonicalname -Server $GC
$domain = $ADUser.CanonicalName.Split('/',2)[0]
$dc = Get-ADDomainController -Discover -DomainName $domain -SiteName Matriz | select -ExpandProperty hostname
$desc = 'Ferias/Afastamento - ' + (Get-Date)

   
# Verificação de usuario existente
if (-not $ADUser) {
    write-output "Usuário não existe!"
}
else{

    # Habilitando OOF (Out-Of-Office) caso não esteja habilitado
    if ($oofmsg) {
        
        # Verifica estado OOF do usuario
        if ((Get-MailboxAutoReplyConfiguration -Identity $username -DomainController $dc).autoreplystate -eq 'Disabled') {
            Set-MailboxAutoReplyConfiguration -Identity $username -InternalMessage $oofmsg -ExternalMessage $oofmsg -AutoReplyState:Enabled -DomainController $dc
        }
    }

    # Desabilita a conta no AD
    Disable-ADAccount -Identity $username -Server $dc
    Set-ADObject -Identity $aduser.ObjectGUID -Description $desc -Server $dc

    # Desabilita a conta no Lync
    Set-CsUser -Identity $username -Enabled $false -DomainController $dc

    # Mensagem de retorno
    Write-Output "Usuário desabilitado!"
}
