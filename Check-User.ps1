
# Definição de variaveis mandatorias
param(
    [Parameter(Position=0,Mandatory=$true)]
    [string]$Username,
    [Parameter(Position=1)]
    [string]$Name
    )

# Abrindo sessão com modulo do ActiveDirectory
Import-Module ActiveDirectory

# Definição de variaveis
$GC = 'sp01.local:3268'
$ADUsername = Get-ADUser -Filter {(samAccountName -eq $username)} -properties canonicalname,enabled -Server $GC


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
        
    # Retorno dos dados do usuario com status 
    $result = ("Nome...: " + $ADUsername.Name + "&" +"Usuario: " + "*" + $ADUsername.SamAccountName + "*" + "&" + "Status.: " + $status).Split("&")
    return $result
}
elseif ($ADName) {
    $ADName = Get-ADUser -Filter {(Name -eq $name)} -properties canonicalname,enabled,ipphone -Server $GC
    switch -Regex ($ADName.CanonicalName[-1]) {
        "Participantes" {
            if ($ADName.Enabled -eq $false) {
                $status = 'Férias/Afastamento'
            }
            else {
                $status = 'Ativo'
            }
        }
        "Desligados" {
            $status = 'Desligado'
        }
            
    }
    # Retorno dos dados do usuario com status 
    $result = ("Nome...: " + $ADName.Name + "&" +"Usuario: " + "*" + $ADName.SamAccountName + "*" + "&" + "Status.: " + $status).Split("&")
    return $result

}
else {
    Write-Output "Usuario ou Nome não existe!"
}
