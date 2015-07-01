#####################################################
#         << Criação de usuários >>                 #
#                                                   #
# 1 - Criação de contas no AD                       #
#   1.1 - Adicionar em grupo                        #
# 2 - Criação de mailbox no Exchange                #
# 3 - Ativação de acesso no Lync                    #
#                                                   #
# Coded by Robson Reis Bispo                        #
# Last update - 06/2015                             #
#####################################################

# Define parametro requerido para o arquivo CSV
param(
[Parameter(Position=0,Mandatory=$true)]
[string]$Domain,
[Parameter(Position=1,Mandatory=$true)]
[string]$Username,
[Parameter(Position=2,Mandatory=$true)]
[string]$Givenname,
[Parameter(Position=3,Mandatory=$true)]
[string]$Sn,
[Parameter(Position=4,Mandatory=$true)]
[string]$Title,
[Parameter(Position=5,Mandatory=$true)]
[string]$Departament,
[Parameter(Position=6,Mandatory=$true)]
[string]$Ipphone
)

# Função para verificação do usuario
function Find-User {

    # Definição de variaveis mandatorias
    param(
    [Parameter(Position=0,Mandatory=$true)]
    [string]$Username,
    [Parameter(Position=1,Mandatory=$true)]
    [string]$Name
    )

    # Abrindo sessão com modulo do ActiveDirectory
    Import-Module ActiveDirectory

    # Definição de variaveis
    $GC = $dc + ':3268'

    # Validação do usuario pelo username
    $ADUsername = Get-ADUser -Filter {(samAccountName -eq $username)} -properties canonicalname,enabled,ipphone -Server $GC

    # Validação do usuario pelo username
    $ADName = Get-ADUser -Filter {(Name -eq $name)} -properties canonicalname,enabled -Server $GC


    if ($ADUsername) {
        switch -Regex ($ADUsername.CanonicalName) {
            "Desligados" {
                $status = 'Desligado'
            }
            "Participantes" {
                if ($ADUsername.Enabled -eq $false) {
                    $status = 'Férias/Afastamento'
                }
                else {
                    $status = 'Ativo'
                }
            }
        }
          $result = ("Nome...: " + $ADUsername.Name + "&" +"Usuario: " + "*" + $ADUsername.SamAccountName + "*" + "&" + "Status.: " + $status).Split("&")
          return $true, $result
    }
    elseif ($ADName) {
            switch -Regex ($ADName.CanonicalName) {
                "Participantes" {
                    if ($ADName.Enabled -eq $false) {
                        $status = 'Férias/Afastamento'
                        $result = ("Nome...: " + $ADName.Name + "&" +"Usuario: " + "*" + $ADName.SamAccountName + "*" + "&" + "Status.: " + $status).Split("&")
                        return $true, $result
                    
                    }
                    else {
                        $status = 'Ativo'
                        $result = ("Nome...: " + $ADName.Name + "&" +"Usuario: " + "*" + $ADName.SamAccountName + "*" + "&" + "Status.: " + $status).Split("&")
                        return $true, $result
                    }
                }
                "Desligados" {
                    $status = 'Desligado'
                    return $false
                }
            }
    }
    else {
        return $false
    }
}

# Função para criação de mailbox no Exchange
function New-Mbx {


    # Definição de variaveis mandatorias
    param(
    [Parameter(Position=0,Mandatory=$true)]
    [string]$Site,
    [Parameter(Position=1,Mandatory=$true)]
    [string]$Username,
    [Parameter(Position=2,Mandatory=$true)]
    [string]$Title
    )

    
    # Definição da mailbox database a partir do site(localidade) do usuario
    Switch -Regex ($site) {
        "SP" { $dbpref = $site + "-"
               Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
             }
        "MEX|BH|POA|JV" { $dbpref = $site + "-" 
                          $ExSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ixion.sp01.local/PowerShell/ -Authentication Kerberos -AllowRedirection
                          [void](Import-PSSession $ExSession)
                        }
        default { $dbpref = "FL-" 
                  Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
                }
    }


    # Definição da mailbox database a partir do cargo(title) do usuario
    Switch -Regex ($title) {
        "Coordenador|Lider|Supervisor" { $dbsuf = "Coordenadores" }
        "Gerente|Gestor" { $dbsuf = "Gerentes" }
        "Diretor|Gerente Exec|Gestor Exec" { $dbsuf = "Diretor" }
        default { $dbsuf = "Participantes" }
    }


        # Definição da mailbox database
    Do {
        $mbxpref = $dbpref + $dbsuf
        Switch -Regex ($mbxpref) {
            "BH-Part|POA-Part|MEX-Part" { $mbx = $mbxpref + (get-random -Minimum 1 -Maximum 3).ToString().PadLeft(2,"0") }
            "JV-Part" { $mbx = $mbxpref + (Get-Random -InputObject 1,3,4).ToString().PadLeft(2,"0") }            
            "SP-Part" { $mbx = $mbxpref + (get-random -Minimum 3 -Maximum 13).ToString().PadLeft(2,"0") }
            "FL-Part" { $mbx = $mbxpref + (get-random -Minimum 3 -Maximum 7).ToString().PadLeft(2,"0") }
            
            "SP-Coord|FL-Coord" { $mbx = $mbxpref + "01" }
            
            "SP-Gere|FL-Gere" { $mbx = $mbxpref + "01" }
            
            default { $mbx = $mbxpref } 
        }
        
        # Contagem da quantidade de mailbox na database
        $mbxsize = (Get-Mailbox -Database $mbx -IgnoreDefaultScope -ResultSize Unlimited).count

    }while ($mbxsize -gt 500)


    # Habilitando a mailbox
    [void](Enable-Mailbox -Identity $username -Database $mbx -DomainController $dc)
    Write-Output "2/3 OK: Conta habilitada no Exchange"

}


# Termina o script ao primeiro sinal de erro / Esconde mensagens de warning
$ErrorActionPreference = "Stop"
$WarningPreference = "SilentlyContinue"

# Abrindo sessão com o modulo do Lync
Import-Module Lync


# Definição variaveis
$FE = 'achilles.sp01.local'
$dc = Get-ADDomainController -Discover -DomainName ($domain + ".local") -SiteName Matriz | select -ExpandProperty hostname
$ou = "OU=Participantes,OU=Usuarios,OU=\#TOTVS,dc=" + $domain + ",dc=local"
$DisplayName = ($givenname + " " + $sn )
$Name = $DisplayName
$UPN = $UserName + "@" + $domain.ToLower() + ".local"
$pass = (ConvertTo-SecureString "totvs@123" -AsPlainText -Force)
$site = $domain.Substring(0,$domain.Length-2)


# Validação se o usuario ja existe
$ADUser = (Find-User -Username $username -Name $Name)


# Definição do grupo informativo a partir do site(localidade) do usuario
Switch -Regex ($site) {
    "RJ" { $group = "fl.riodejaneiro"}
    "DF" { $group = "TOTVS BRASILIA" }
    "REC" { $group = "TOTVS RECIFE" }
    "SSA" { $group = "totvs.salvador"}
    "ARG" { $group = "fl.argentina"}
    "MEX" { $group = "fl.mexico"}
    "BH" { $group = "TOTVS Belo Horizonte"}
    "JV" { $group = "jv.informativos"}
    "POA" { $group = "poa.totvs"}
    default { $group = "totvs matriz" }
}
        
        
# Se usuario não existir, efetuar a criação
if ($ADUser[0] -eq $false) {
    New-ADUser -Name $displayname `
               -GivenName $givenname `
               -Surname $sn `
               -DisplayName $DisplayName `
               -UserPrincipalName $UPN `
               -Path $ou `
               -Title $title `
               -Department $departament `
               -SamAccountName $UserName `
               -OtherAttributes @{ipphone = $ipphone} `
               -AccountPassword $pass `
               -Server $dc `
               -Enabled $true
                        
    # Inserindo no grupo de e-mail de informativos
    Add-ADGroupMember -Identity $group -Server $dc -Members $username
    
    # Retorno da mensagem de criação com sucesso
    Write-Output ("1/3 OK: " + $DisplayName + " (" + $UserName + ")")

    
    # Criação da Mailbox
    New-Mbx -Site $site -Username $Username -Title $Title

    
    # Ativação no Lync
    Enable-CsUser -Identity $Username -RegistrarPool $FE -SipAddressType EmailAddress -DomainController $dc
    Write-Output "3/3 OK: Conta habilitada no Lync"

         
}

# Validação se usuário ja existe
Else {
    Write-Output ("ERRO: Usuario ja existe!")
    return $ADUser[1]
}
