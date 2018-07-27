[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
 
#Using Get-SPSite in MOSS 2007
function global:Get-SPSite($url)
 {
    return new-Object Microsoft.SharePoint.SPSite($url)
 }
 

# Initial Variables
$Url="http://w2k8teepmap03:33599/"
$Folder = "http://w2k8teepmap03:33599/gestao/gestao de contratos"


# Getting the web 
$site = Get-SPSite $Url
$web = $site.RootWeb

#Getting the permission on Folder
$srcFolder= $Web.GetFolder($Folder)
$srcFolder
$srcFolder.Item.RoleAssignments | Format-Table -Property Member,RoleDefinitionBindings
