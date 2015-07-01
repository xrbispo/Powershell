##########################################################
##########################################################
#               << Geração de username >>                #
#                                                        #
# 1 - Criação de username a partir do nome completo      #
#                                                        #
#        Nome1    Nome2  Sobrenome1  Sobrenome2          #
#         Luis  Fernando   Alves       Pereira           #
#                                                        #
#  Nome1 + Sobrenome2 = luis.pereira                     #
#  Nome1 + Sobrenome1 = luis.alves                       #
#  Nome2 + Sobrenome2 = fernando.pereira                 #
#  Nome2 + Sobrenome1 = fernando.alves                   #
#                                                        #
#  Letra1Nome1 + Sobrenome2 = lpereira                   # 
#  Letra1Nome1 + Sobrenome1 = lalves                     #
#  Opções com ".", "-", "_" e ""                         #
#  DESENVOLVER - Se nenhum, inclui numero ao fim         #
#                                                        #
# Coded by Robson Reis Bispo                             #
# 04/2015                                                #
##########################################################

# Define parametro requerido para o arquivo CSV
param(
[Parameter(Position=0,Mandatory=$true)]
[string]$givenname,
[Parameter(Position=1,Mandatory=$true)]
[string]$sn
)

$ErrorActionPreference = "Stop"

Import-Module ActiveDirectory

# Definição variaveis gerais
$GC = 'sp01.local:3268'
$fullName = ($givenname + " " + $sn )
$firstName = $givenname.ToLower() -split " "
$lastName = $sn.ToLower() -split " "
$firstletter = ($givenname.Substring(0,1)).ToLower()
$empty = $null
[array]::Reverse($lastName)
   
# Loop: Nome + . + SobreNome
for ($i = 0; $i -lt $firstName.length; $i++) {
    for ($j = 0; $j -lt $lastName.Length; $j++){
        $username = ($firstname[$i] + "." + $lastName[$j])
        if ( -not(($lastName[$i] -eq "da") -or ($lastName[$i] -eq "de") -or ($lastName[$i] -eq "dos"))) {
            $ADUser = Get-ADUser -Filter {(samAccountName -eq $username)} -Server $GC
            if (-not $ADUser) {
                return $username
            }
            else {
                $empty++
            }
        }
    }
}

# Loop: Nome + - + SobreNome
if ($empty -eq $lastName.Length) {
                for ($i = 0; $i -lt $firstName.length; $i++) {
                               for ($j = 0; $j -lt $lastName.Length; $j++){
                                               $username = ($firstname[$i] + "-" + $lastName[$j])
                                               if ( -not(($lastName[$i] -eq "da") -or ($lastName[$i] -eq "de") -or ($lastName[$i] -eq "dos"))) {
                                                               $ADUser = Get-ADUser -Filter {(samAccountName -eq $username)} -Server $GC
                                                               if (-not $ADUser) {
                                                                              return $username
                                                               }
                                                               else {
                                                                              $empty++
                                                               }
                                               }
                               }
                }
}

# Loop: Nome + _ + SobreNome
if ($empty -eq $lastName.Length) {
                for ($i = 0; $i -lt $firstName.length; $i++) {
                               for ($j = 0; $j -lt $lastName.Length; $j++){
                                               $username = ($firstname[$i] + "_" + $lastName[$j])
                                               if ( -not(($lastName[$i] -eq "da") -or ($lastName[$i] -eq "de") -or ($lastName[$i] -eq "dos"))) {
                                                               $ADUser = Get-ADUser -Filter {(samAccountName -eq $username)} -Server $GC
                                                               if (-not $ADUser) {
                                                                              return $username
                                                               }
                                                               else {
                                                                              $empty++
                                                               }
                                               }
                               }
                }
}

# Loop: Nome + SobreNome
if ($empty -eq $lastName.Length) {
                for ($i = 0; $i -lt $firstName.length; $i++) {
                               for ($j = 0; $j -lt $lastName.Length; $j++){
                                               $username = ($firstname[$i] + $lastName[$j])
                                               if ( -not(($lastName[$i] -eq "da") -or ($lastName[$i] -eq "de") -or ($lastName[$i] -eq "dos"))) {
                                                               $ADUser = Get-ADUser -Filter {(samAccountName -eq $username)} -Server $GC
                                                               if (-not $ADUser) {
                                                                              return $username
                                                               }
                                                               else {
                                                                              $empty++
                                                               }
                                               }
                               }
                }
}

# Loop: LetraNome + Sobrenome
if ($empty -eq $lastName.Length) {
    $empty = $null
    for ($i = 0; $i -lt $lastName.Length; $i++) {
       $username = ($firstletter + $lastName[$i])
       if ( -not(($lastName[$i] -eq "da") -or ($lastName[$i] -eq "de") -or ($lastName[$i] -eq "dos"))) {
            $ADUser = Get-ADUser -Filter {(samAccountName -eq $username)} -Server $GC
            if (-not $ADUser) {
                return $username
            }
            else {
                $empty++
            }
        } 
    }
}

# Loop: LetraNome + . + Sobrenome
if ($empty -eq $lastName.Length) {
    $empty = $null
    for ($i = 0; $i -lt $lastName.Length; $i++) {
       $username = ($firstletter + "." + $lastName[$i])
       if ( -not(($lastName[$i] -eq "da") -or ($lastName[$i] -eq "de") -or ($lastName[$i] -eq "dos"))) {
            $ADUser = Get-ADUser -Filter {(samAccountName -eq $username)} -Server $GC
            if (-not $ADUser) {
                return $username
            }
            else {
                $empty++
            }
        } 
    }
}

# Loop: LetraNome + - + Sobrenome
if ($empty -eq $lastName.Length) {
    $empty = $null
    for ($i = 0; $i -lt $lastName.Length; $i++) {
       $username = ($firstletter + "-" + $lastName[$i])
       if ( -not(($lastName[$i] -eq "da") -or ($lastName[$i] -eq "de") -or ($lastName[$i] -eq "dos"))) {
            $ADUser = Get-ADUser -Filter {(samAccountName -eq $username)} -Server $GC
            if (-not $ADUser) {
                return $username
            }
            else {
                $empty++
            }
        } 
    }
}

# Loop: LetraNome + _ + Sobrenome
if ($empty -eq $lastName.Length) {
    $empty = $null
    for ($i = 0; $i -lt $lastName.Length; $i++) {
       $username = ($firstletter + "_" + $lastName[$i])
       if ( -not(($lastName[$i] -eq "da") -or ($lastName[$i] -eq "de") -or ($lastName[$i] -eq "dos"))) {
            $ADUser = Get-ADUser -Filter {(samAccountName -eq $username)} -Server $GC
            if (-not $ADUser) {
                return $username
            }
            else {
                $empty++
            }
        } 
    }
}


if ($empty -eq $lastName.Length) {
    Write-Output "Sem mais sugestões"
}
