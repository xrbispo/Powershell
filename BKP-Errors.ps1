# Lista os jobs do NetBackup que apresentaram falha nas ultima janela
# e retorna a saida para o monitoramento com a contagem total de jobs e a lista de clients



# Argumentos
Param(
    [Parameter(Mandatory=$true,Position=1)][ValidateRange(1,20000)][int]$Warning,
    [Parameter(Mandatory=$true,Position=2)][ValidateRange(2,20000)][int]$Critical    
)

# Variaveis globais
$NewSummary = @()
$ClientList = @()
$StartDate = "{0:MM\/dd\/yyyy 22:00:00}" -f ((Get-date).AddDays(-1))
$EndDate = "{0:MM\/dd\/yyyy 11:00:00}" -f (Get-date)
$cmd = 'D:\''Program Files''\Veritas\NetBackup\bin\admincmd\bperror.exe -backstat -d $StartDate -e $EndDate'



$ok = "OK - Não existem jobs com falha"
$preWarning = "WARNING -"
$preCritical = "CRITICAL -"


# Executa o comando
$summary = (Invoke-Expression $cmd)



# Filtrando os resultados do comando
foreach ($line in $summary) {
    
    # Quebra cada linha do sumario em um array
    $array = $line -replace '\s+',' '
    
    # Não trata os backups com sucesso, politicas internas do nbumaster e backups incompletos
    if ($array.split()[18] -ne "0" -and $array.split()[13] -ne "SLP_Internal_Policy" -and $array.split()[18] -ne "1") 
    {
        # Cria novo array apenas com os campos escolhidos
        $newArray= new-object psobject -property @{ 
            Client = $array.split()[11]
            StatusCode = $array.split()[18]
            Policy = $array.split()[13]
        }
        $NewSummary += $newArray
        $ClientList += $newArray.client
    }    
}


# Geração dos dados de saida
$ClientListTotal = $ClientList | sort -uniq
$totalFalhas = $ClientListTotal.count 
$sufRetorno = "Existem $totalFalhas servidores com falha:"



# Saida monitoramento 
if ($totalFalhas -eq 0)
{
    Write-Output $ok
    Exit 0
}
elseif ($totalFalhas -ge $warning)
{
    Write-Output "$preWarning $sufRetorno $ClientListTotal"
    Exit 1
}
elseif ($totalFalhas -ge $critical)
{
    Write-Output "$preCritical $sufRetorno $ClientListTotal"
    Exit 2
}
