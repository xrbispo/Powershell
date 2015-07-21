####################################################################
#             << Adicionar/Remover usuários de grupo s>>           #
#                                                                  #
# Coded by Robson Reis Bispo                                       #
# Last update - 07/2015                                            #
####################################################################

# Define parametros requeridos
param(
[Parameter(Position=0,Mandatory=$true)]
[string]$username,
[Parameter(Position=1,Mandatory=$true)]
[string]$groupname,
[Parameter(Position=2,Mandatory=$true)]
[string]$action
)

$ErrorActionPreference = "Stop"

# Abrindo sessão com modulo do ActiveDirectory
Import-Module ActiveDirectory

# Função para verificação do usuario
function Find-User {

    # Definição de variaveis mandatorias
    param(
    [Parameter(Position=0,Mandatory=$true)]
    [string]$Username
    )

    # Definição de variaveis
    $GC = 'sp01.local:3268'
    $ADUsername = Get-ADUser -Filter {(samAccountName -eq $username)} -Properties canonicalname -Server $GC

    if ($ADUsername) {
        return $ADUsername
    }
    else {
        return $false
    }
}


# Função para verificação do grupo
function Find-Group {

    # Definição de variaveis mandatorias
    param(
    [Parameter(Position=0,Mandatory=$true)]
    [string]$groupname
    )

    # Definição de variaveis
    $GC = 'sp01.local:3268'
    $ADGroupname = Get-ADGroup -Filter {(samAccountName -eq $groupname)} -Properties canonicalname -Server $GC

    if ($ADGroupname) {
        return $ADGroupname
    }
    else {
        return $false
    }
}

# Validação do usuario e do grupo
$ADUser = Find-User($username)
$ADGroup = Find-Group($groupname)

# Definição do domain controller
$domain = $ADGroup.CanonicalName.Split("/")[0]
$dc = Get-ADDomainController -Discover -DomainName $domain -SiteName Matriz | select -ExpandProperty hostname

if ($ADUser -and $ADGroup) {
    if ($action.ToLower() -eq "add"){
        Set-ADObject -Identity $ADGroup.DistinguishedName -Add @{member=$ADUser.DistinguishedName} -Server $dc
        #Add-ADGroupMember -Identity $groupname -Members $username -Server $dc 
        Write-Output "Usuario adicionado!"
    }
    elseif ($action.ToLower() -eq "remove"){
        Set-ADObject -Identity $ADGroup.DistinguishedName -Remove @{member=$ADUser.DistinguishedName} -Server $dc
        #Remove-ADGroupMember -Identity $groupname -Members $username -Server $dc 
        Write-Output "Usuario removido!"
    }
    else{
        Write-Output "Ação invalida. Entre com ADD ou REMOVE no parametro ACTION."
    }
}
else {
    Write-Output "Usuario ou grupo inexistente"
}
