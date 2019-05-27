#####################################################################################################################
#  
#  Rename-VMDisks.ps1  (v1)
#  coded by Robson Bispo - 05/21/2019
#  
#  This script gets all the vmdk files from the vm and rename them to the pattern defined on VCAMP. (-sdb,-sdc....)
#
#  You have to insert 2 paramenters: 
#    Datacenter (IRV4 or BNA4)
#    VM Name (Make sure the server is turned off first)
#   
#   Ex: Renam-VMDisks -Datacenter BNA4 -VM Server001
#
#####################################################################################################################



# Parameters and Global variables
Param([parameter(Mandatory=$true)]$Datacenter,  
[parameter(Mandatory=$true)]$VM
)

$DownloadFolder = $env:USERPROFILE + '\Downloads'
$Datacenter = $Datacenter.ToUpper()

switch($Datacenter){
"BNA4" {$vCenterServer = 'vcenter0001.bna4.vtscloud.io' }  

"IRV4" {$vCenterServer = 'vcenter0002.irv4.vtscloud.io' } 

default {"Invalid Datacenter" 
       break }
}

# Functions
function CreateHDList {
Param([parameter(Mandatory=$true)]$VMName, 
   [parameter(Mandatory=$true)]$DownloadFolder
)

$HDListFile = $DownloadFolder + '\' + $VMName + '-Disks.txt'

Write-Host
Write-Host 'Creating HD list...' -ForegroundColor Yellow
try {
 $HDList = Get-VM $VMName | Get-HardDisk | 
 Select @{N='VM';E={$_.Parent.Name}}, @{N='PowerState'; E={$_.Parent.PowerState}}, ID, Name, Filename, 
          @{N='SCSIid';E={
                           $hd = $_
                           $ctrl = $hd.Parent.Extensiondata.Config.Hardware.Device | where{$_.Key -eq $hd.ExtensionData.ControllerKey}
                            "$($ctrl.BusNumber):$($_.ExtensionData.UnitNumber)"
          }} 
 $HDlist | Out-File $HDListFile
 Write-Host '\nHD list created at'  $HDListFile -ForegroundColor Green 
 $HDList
}
catch {
 Write-Host
 Write-Host '<CreateHDList Fail>'
 Write-Output $_.Exception.Message
 break
} 
}




####### Script Begin #######


# Connect to vCenter
If (!$vCenterCredentials) {
$vCenterCredentials = Get-Credential -
}

Write-Host
Write-host 'Connecting to vCenter...' -ForegroundColor Yellow
if ($vCenterCredentials) {
if (!$vCenterSession) {
 $vCenterSession = Connect-VIServer -Server $vCenterServer -Credential $vCenterCredentials
}
else {
 Connect-VIServer $vCenterServer -Session $vCenterSession.SessionId
}
}

# Check if VM is PoweredOn
Write-Host
Write-host 'Checking VM power state...' -ForegroundColor Yellow
if ((Get-VM $VM).PowerState -eq 'PoweredOn') {
Write-host 'Please turn off VM first!' -ForegroundColor Red
break
}

# Get HD List and export to txt file for future reference
$HDList = CreateHDList -VMName $VM -DownloadFolder $DownloadFolder

# Detach all disks
Write-Host
Write-Host 'Detaching HDs...' -ForegroundColor Yellow
Get-HardDisk -vm $VM | Remove-HardDisk -Confirm:$false


# Main Code
Write-Host
Write-Host 'Renaming HDs...' -ForegroundColor Yellow
Foreach ($HD in $HDList) {

$FileNameSplit = $HD.Filename.Trim('[').Split(' /').Trim(']')
$FilePath = "vmstore:\$datacenter\" + $FileNameSplit[0] + "\" + $FileNameSplit[1] + "\"

$OriginalHDName = $FileNameSplit[2]
$OriginalHDFlatName =  $FileNameSplit[2].Trim('.vmdk') + "-flat.vmdk"

$OriginalHDFilePath = $FilePath + $OriginalHDName
$OriginalHDFlatFilePath = $FilePath + $OriginalHDFlatName


# Define new HD name
switch($hd.Name){
"Hard disk 1" {$NewHDName = $FileNameSplit[1] + ".vmdk" 
            $NewHDFlatName = $FileNameSplit[1] + "-flat.vmdk"} 

"Hard disk 2" {$NewHDName = $FileNameSplit[1] + "-sdb.vmdk" 
            $NewHDFlatName = $FileNameSplit[1] + "-sdb-flat.vmdk"}

"Hard disk 3" {$NewHDName = $FileNameSplit[1] + "-sdc.vmdk"  
            $NewHDFlatName = $FileNameSplit[1] + "-sdc-flat.vmdk"}

"Hard disk 4" {$NewHDName = $FileNameSplit[1] + "-sdd.vmdk"  
            $NewHDFlatName = $FileNameSplit[1] + "-sdd-flat.vmdk"}

"Hard disk 5" {$NewHDName = $FileNameSplit[1] + "-sde.vmdk"  
            $NewHDFlatName = $FileNameSplit[1] + "-sde-flat.vmdk"}

"Hard disk 6" {$NewHDName = $FileNameSplit[1] + "-sdf.vmdk"  
            $NewHDFlatName = $FileNameSplit[1] + "-sdf-flat.vmdk"}

"Hard disk 7" {$NewHDName = $FileNameSplit[1] + "-sdg.vmdk"  
            $NewHDFlatName = $FileNameSplit[1] + "-sdg-flat.vmdk"}

default {"Invalid entry" 
       break }
}

$NewFilePath = $HD.Filename.Split('/')[0]  + '/' + $NewHDName


# Edit pointer file(.vmdk) to match new flat filename(-flat.vmdk)
try {
 Copy-DatastoreItem -Item $OriginalHDFilePath -Destination D:\Downloads
 ((Get-Content -path D:\Downloads\$OriginalHDName -Raw) -replace $OriginalHDFlatName,$NewHDFlatName) | Set-Content -Path D:\Downloads\$OriginalHDName
 Copy-DatastoreItem -Item D:\Downloads\$OriginalHDName -Destination $FilePath

 # Rename HD files
 Rename-Item $OriginalHDFilePath -NewName $NewHDName
 Rename-Item $OriginalHDFlatFilePath -NewName $NewHDFlatName


 #Reattach HD
 New-HardDisk -VM $HD.VM -DiskPath $NewFilePath | Out-Null

 Write-Host $HD.vm 'renamed successfully!' -ForegroundColor Green
}
catch {
 Write-Host '<RenameHDs Fail>' -ForegroundColor Red
 Write-Output $_.Exception.Message
 break
}
}

# Change ScsiController type because the default type(LSI Logic Parallel) does not boot the HardDisks
Get-ScsiController $HD.VM | Set-ScsiController -Type VirtualLsiLogicSAS | Out-Null
Write-Host 
Write-Host 'SCSI type set to SAS' -ForegroundColor Green

Write-Host
Write-Host 'All disks finished!!!' -ForegroundColor Green
Write-host 'Please, check now if all disks are attached ok, compare with the file at'$DownloadFolder  -ForegroundColor Yellow
Write-host 'Check if Scsi Controller is set to type SAS and start the VM' -ForegroundColor Yellow
