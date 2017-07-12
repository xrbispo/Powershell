# Lista os jobs do NetBackup que apresentaram falha nas ultimas 24 horas
# e retorna a saida para o check_mk com a contagem total de jobs e a lista de clients



# Argumentos
Param(
    [Parameter(Mandatory=$true,Position=1)][ValidateRange(1,20000)][int]$Warning,
    [Parameter(Mandatory=$true,Position=2)][ValidateRange(2,20000)][int]$Critical    
)

# Variaveis globais
$cmd = 'D:\''Program Files''\Veritas\NetBackup\bin\admincmd\bperror.exe -s ERROR -backstat'
$NewSummary = @()
$ClientList = @()

$ok = "0 BKP-Errors - OK - Não existem jobs com falha"
$preWarning = "1 BKP-Errors - WARNING -"
$preCritical = "2 BKP-Errors - CRITICAL -"


# Executa o comando
$summary = (Invoke-Expression $cmd)



# Filtrando os resultados do comando
foreach ($line in $summary) {
    
    # Quebra cada linha do sumario em um array
    $array = $line -replace '\s+',' '
    
    if ($array.split()[18] -ne "0" -and $array.split()[13] -ne "SLP_Internal_Policy") # Não trata os backups com sucesso (Status Code 0) e politicas internas do nbumaster
    {
        # Cria novo array apenas com os campos escolhidos
        $newArray= new-object psobject -property @{ 
            Client = $array.split()[11]
            StatusCode = $array.split()[18]
        }
        $NewSummary += $newArray
        $ClientList += $newArray.client
    }    
}


# Geração dos dados de saida
$totalFalhas = $newSummary.count 
$sufRetorno = "Existem $totalFalhas jobs com falha:"






# Saida Check_mk 
Write-Output "<<<local>>>"
if ($totalFalhas -eq 0)
{
    Write-Output $ok
}
elseif ($totalFalhas -le 10)
{
    Write-Output "$preWarning $sufRetorno $ClientList"
}
else
{
    Write-Output "$preCritical $sufRetorno $ClientList"
}
