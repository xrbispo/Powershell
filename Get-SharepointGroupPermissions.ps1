[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
$SiteUrl = "http://w2k8teepmap03:33599/"
$SPSite = New-Object Microsoft.SharePoint.SPSite($SiteUrl);
$outfile = $SPSite.RootWeb.Title + "_Permissions.csv"

"Web Title,Web URL,List Title,User or Group,Role,Inherited" | out-file $outfile

foreach ($web in $SPSite.AllWebs) 
{ 
	if ($web.HasUniqueRoleAssignments) 
        { 
          $SPRoleAssignments = $web.RoleAssignments; 
          foreach ($SPRoleAssignment in $SPRoleAssignments) 
          { 
            foreach ($SPRoleDefinition in $SPRoleAssignment.RoleDefinitionBindings) 
            { 
                $web.Title + "," + $web.Url + "," + "N/A" + "," + $SPRoleAssignment.Member.Name + "," + $SPRoleDefinition.Name + "," + $web.HasUniqueRoleAssignments | out-file $outfile -append 
            }
          }
        } 
            
        foreach ($list in $web.Lists)
        {
           if ($list.HasUniqueRoleAssignments)
           {
             $SPRoleAssignments = $list.RoleAssignments; 
             foreach ($SPRoleAssignment in $SPRoleAssignments) 
             {
               foreach ($SPRoleDefinition in $SPRoleAssignment.RoleDefinitionBindings)
               {
                    $web.Title + "," + $web.Url + "," + $list.Title + "," + $SPRoleAssignment.Member.Name + "," + $SPRoleDefinition.Name | out-file $outfile -append
               }
             }
           }
        }
}
