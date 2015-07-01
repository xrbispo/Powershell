####################################################################
#                  << Desligamento de usuários >>                  #
#                                                                  #
# 1 - Desabilita conta no AD                                       #
# 2 - Move para OU=#Desligados                                     #
# 3 - Desabilita mailbox no Exchange                               #
# 4 - Remove do servidor do Lync                                   #
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
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn


# Definição variaveis gerais
$GC = 'sp01.local:3268'
$ADUser = Get-ADUser -Filter {(samAccountName -eq $username)} -properties canonicalname,description -Server $GC
$domain = $ADUser.CanonicalName.Split('/',2)[0]
$dc = Get-ADDomainController -Discover -DomainName $domain -SiteName Matriz | select -ExpandProperty hostname
$ou = "OU=\#Desligados,OU=Usuarios,OU=\#TOTVS,dc=" + $domain.Split('.')[0] + ",dc=local"
$desc = "Desligado - " + (Get-Date)

# Verificação de usuario existente
if (-not $ADUser) {
    write-output "Usuário não existe!"
}
else{
    switch -Regex ($ADUser.CanonicalName) {
        "Desligados" {
            Write-Output "Usuario ja desligado!"
        }
        default {
            # Desabilita a conta no AD e rotula com data do desligamento
            Disable-ADAccount -Identity $username -Server $dc
            Set-ADObject -Identity $aduser.ObjectGUID -Description $desc -Server $dc

            # Desvincula mailbox da conta do AD
            Disable-Mailbox -Identity $username -DomainController $dc -Confirm:$false

            # Remove a conta do servidor do Lync
            Disable-CsUser -Identity $aduser.DistinguishedName -DomainController $dc

            # Move conta de usuario para OU=#Desligados
            Move-ADObject -Identity $aduser.ObjectGUID -TargetPath $ou -Server $dc

            # Mensagem de retorno
            Write-Output "Usuário desligado!"        
        }
    }
    
}
