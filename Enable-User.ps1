####################################################################
#                  << Reativação de usuários >>                    #
#                                                                  #
# 1 - Reativa conta no AD                                          #
# 2 - Reativa conta no Lync                                        #
# 3 - Desabilita mensagem de ausencia temporaria(OOF) no Exchange  #
#                                                                  #
# Coded by Robson Reis Bispo                                       #
# Last update - 06/2015                                            #
####################################################################


# Define parametros requeridos
param(
[Parameter(Position=0,Mandatory=$true)]
[string]$username
)

$ErrorActionPreference = "Stop"

# Importação dos modulos
Import-Module ActiveDirectory
Import-Module Lync
#$ExSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://morpheus.sp01.local/PowerShell/ -AllowRedirection
#[void](Import-PSSession $ExSession)

# Definição variaveis gerais
$GC = 'sp01.local:3268'
$ADUser = Get-ADUser -Filter {(samAccountName -eq $username)} -properties canonicalname -Server $GC
$domain = $ADUser.CanonicalName.Split('/',2)[0]
$dc = Get-ADDomainController -Discover -DomainName $domain -SiteName Matriz | select -ExpandProperty hostname
$desc = $null

   
# Verificação de usuario existente
if (-not $ADUser) {
    write-output "Usuário não existe!"
}
else{
    # Desabilita a conta no AD
    Enable-ADAccount -Identity $username -Server $dc
    Set-ADObject -Identity $aduser.ObjectGUID -Description $desc -Server $dc
    
    # Desabilita a conta no Lync
    Set-CsUser -Identity $username -Enabled $true -DomainController $dc

    # Desabilitando OOF (Out-Of-Office)
    #Set-MailboxAutoReplyConfiguration -Identity $username -AutoReplyState:Disabled -DomainController $dc
    
    # Mesangem de retorno
    Write-Output "Usuário reabilitado!"

}
