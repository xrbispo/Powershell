# Global Variables
$ServiceName = "Spooler"


# Initialize/Reset Variables
$CheckStatusCode = "0"
$CheckStatusName = ""
$CheckStatusDescription = ""
$CheckStatusColor = ""


# Get Service Details
$Service = Get-Service -Name $ServiceName
$CheckStatusDescription = $Service.DisplayName + " is " + $Service.Status


# Check Service Status
if ($Service.Status -eq "StopPending" -or $Service.Status -eq "Stopped" ) {
    $CheckStatusCode = "2"
}
elseif ($Service.Status -eq "Running") {
    $CheckStatusCode = "0"
} 
else {
    $CheckStatusCode = "1"
}


# Monitoring Variables
if ($CheckStatusCode -eq "2") 
{
	$CheckStatusName = "CRITICAL:"
    $CheckStatusColor = "Red"
} 
elseif ($CheckStatusCode -eq "1") 
{
	$CheckStatusName = "WARNING:"
    $CheckStatusColor = "Yellow"
} 
elseif ($CheckStatusCode -eq "0") 
{
	$CheckStatusName = "OK:"
    $CheckStatusColor = "Green"
}
else {
    $CheckStatusName = "UNKNOW: "
}

# Monitoring Output
Write-Host $CheckStatusName $CheckStatusDescription -ForegroundColor $CheckStatusColor
Exit $CheckStatusCode



