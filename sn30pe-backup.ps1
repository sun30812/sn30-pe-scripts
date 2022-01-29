# Setting Data Drive Label
$data_drive = "sn30-pe-data"

# Check Vaildate Directory
Write-Output "=====sn30 PE [Driver Backup Tool]====="
if ($null -eq $pe_data) {
    Write-Output "$($data_drive) is not available."
    return
} elseif (-not(Test-Path "$($pe_data.DriveLetter):\drivers")) {
    mkdir -p "$($pe_data.DriveLetter):\drivers"
}
$folder_name = Read-Host "Driver Folder Name"
mkdir -p "$($pe_data.DriveLetter):\drivers\$folder_name"
dism /online /export-driver /destination:"$($pe_data.DriveLetter):\drivers\$folder_name"
Write-Output "Backup Complete."
Pause