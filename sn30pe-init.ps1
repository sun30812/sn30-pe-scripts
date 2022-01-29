# Setting Data Drive Label
$data_drive = "sn30-pe-data"

Write-Output "=====sn30 PE [Windows installer]====="
# Check Vaildate Directory
$pe_data = Get-Volume -FileSystemLabel $data_drive
if ($null -eq $pe_data) {
    Write-Output "$($data_drive) is not available."
    return
} elseif (-not(Test-Path "$($pe_data.DriveLetter):\images")) {
    Write-Output "Not found images directory in $($data_drive)."
    return
}

# Select Windows Image
Clear-Host
Write-Output "=====Select Windows Image=====`n"
$image_list = Get-ChildItem "$($pe_data.DriveLetter):\images" -Name
Write-Output "Number`t`tName"
for ($count = 0; $count -lt $image_list.Count; $count++) {
    Write-Output "$count`t`t$($image_list[$count])"
}
$image_file_number = Read-Host "Choose your windows image number"

if ($image_file_number -ge $image_list.Count) {
    Write-Output "Not Found"
    return
}
$image = "$($pe_data.DriveLetter):\images\$($image_list[$image_file_number])"
Write-Output "Loading Image file..."
Get-WindowsImage -ImagePath "$($pe_data.DriveLetter):\images\$($image_list[$image_file_number])" | Format-Table -Property ImageIndex,ImageName,ImageDescription
$image_index = Read-Host "Select image Index number"

# Disk Selection
Clear-Host
Write-Output "=====Select Disk=====`n"
Get-Disk | Format-Table -Property Number,FriendlyName,Size
$disk_number = Read-Host "Select disk number to proceed Installation"

# Driver Selection
Clear-Host
Write-Output "=====Select Driver=====`n"
$driver_list = Get-ChildItem "$($pe_data.DriveLetter):\drivers" -Name
Write-Output "Number`t`tFolder Name"
for ($count = 0; $count -lt $driver_list.Count; $count++) {
    Write-Output "$count`t`t$($driver_list[$count])"
}
$driver_file_number = Read-Host "Select Driver Directory"

if ($driver_file_number -ge $driver_list.Count) {
    Write-Output "Not Found."
    return
}
$driver_path = "$($pe_data.DriveLetter):\drivers\$($driver_list[$driver_file_number])"

# Compact OS
Clear-Host
Write-Output "=====Compact OS=====`n"
$compact_os = $false
Write-Output "Compact OS will be save your storage"
$compact = Read-Host "Activate CompactOS? [yes/no]"
if ($compact -eq "yes") {
    $compact_os = $true
}
# Review Installation
Write-Output "Check your settings."
Write-Output "================="
Write-Output "Image file: $($image)"
Write-Output "Image Index: $($image_index)"
Write-Output "Disk Number: $($disk_number)"
Write-Output "Driver Path: $($driver_path)"
Write-Output "CompactOS: $($compact_os)"
$preceed_answer = Read-Host "Are you sure? [yes/no]"
if ($preceed_answer -ne "yes") {
    Write-Output "Cancle installation."
    return
}

# Perform Action
Clear-Host
Write-Output "=====Start Installation=====`n"
Set-Content -Path "diskpart_work.txt" -Value "sel dis $disk_number"
Add-Content -Path "diskpart_work.txt" -Value $(Get-Content "sn30-pe-diskpart.txt")
diskpart /s diskpart_work.txt
if ($compact_os) {
    dism /apply-image /imagefile:$image /index:$image_index /applydir:W: /compact
} else {
    dism /apply-image /imagefile:$image /index:$image_index /applydir:W: 
}
dism /image:W: /add-driver /driver:$driver_path /recurse /forceunsigned
if ($unattend) {
    Apply-WindowsUnattend -UnattendPath "$($pe_data.DriveLetter):\afterUpdate.xml" -Path "W:"
}
bcdboot W:\windows /s S: /f uefi /l ko-kr
Write-Output "`r`rRebooting in 5 seconds..."
Start-Sleep -Seconds 5
Restart-Computer