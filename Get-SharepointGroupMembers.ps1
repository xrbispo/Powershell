[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
 
#Using Get-SPSite in MOSS 2007
function global:Get-SPSite($url)
 {
    return new-Object Microsoft.SharePoint.SPSite($url)
 }
 
function global:Get-SPWeb($url)
{
  $site= New-Object Microsoft.SharePoint.SPSite($url)
        if($site -ne $null)
            {
               $web=$site.OpenWeb();      
            }
    return $web
}

$URL="http://w2k8teepmap03:33599/"
  
     $site = Get-SPSite $URL
    
     #Write the Header to "Tab Separated Text File"
        "Url `t Website `t GroupName `t UserAccount `t UserName `t E-Mail" | out-file "d:\UsersandGroupsRpt.txt"
         
     #Iterate through all Webs
      foreach ($web in $site.AllWebs)
      {
         #Get all Groups and Iterate through   
         foreach ($group in $Web.groups)
         {
             #Get Permission Levels Applied to the Group  
             $RoleAssignment = $Web.RoleAssignments.GetAssignmentByPrincipal($group)
             $RoleDefinitionNames=""
             foreach ($RoleDefinition in $RoleAssignment.RoleDefinitionBindings)
             { 
                $RoleDefinitionNames+=$RoleDefinition.Name+";"
             }
             
                #Iterate through Each User in the group
                       foreach ($user in $group.users)
                        {
                           #Exclude Built-in User Accounts
                    if(($User.LoginName.ToLower() -ne "nt authority\authenticated users") -and ($User.LoginName.ToLower() -ne "sharepoint\system") -and ($User.LoginName.ToLower() -ne "nt authority\local service"))
                    {
                                "$($web.url) `t $($web.title) `t $($Group.Name):: $($RoleDefinitionNames)  `t  $($user.LoginName)  `t  $($user.name)" | out-file "d:\UsersandGroupsRpt.txt" -append
                             }
                        }
         }
       }
