$version = "0.3b"
$dataDrive = "sn30-pe-data"
Add-Type -AssemblyName System.Windows.Forms
$main = [System.Windows.Forms.Form]::new()
$main.Size = [System.Drawing.Size]::new(700, 400)
$main.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$main.Text = "앱 런처"

function versionInfoClick ($object, $eventArg) {
    [System.Windows.Forms.MessageBox]::Show("현재 버전은 ${version}입니다.`r설정된 데이터 드라이브 위치: $dataDrive", "버전 정보")
}

function appsClick ([System.Windows.Forms.ListView]$object, $eventArg) {
    $pinfo = [System.Diagnostics.ProcessStartInfo]::new()
    switch ($object.SelectedItems[0].Tag) {
        "notepad" { notepad.exe }
        "initScript" { 
            $pinfo.FileName = "powershell.exe"
            $pinfo.Arguments = "-ExecutionPolicy ByPass -c ./sn30pe-init.ps1"
        }
        Default { $pinfo.FileName = $_ }
    }
    [System.Diagnostics.Process]::Start($pinfo)
}

function systemManage ($object, $eventArg, [bool]$isRestart) {
    if ($isRestart) {
        if ([System.Windows.Forms.MessageBox]::Show("시스템을 다시시작하시겠습니까?", "다시시작", [System.Windows.Forms.MessageBoxButtons]::OKCancel) -eq "OK") {
            Restart-Computer
            [System.Windows.Forms.MessageBox]::Show("잠시후 시스템이 다시시작됩니다.", "안내")
        }
    }
    else {
        if ([System.Windows.Forms.MessageBox]::Show("시스템을 종료하시겠습니까?", "시스템 종료", [System.Windows.Forms.MessageBoxButtons]::OKCancel) -eq "OK") {
            Stop-Computer
            [System.Windows.Forms.MessageBox]::Show("잠시후 시스템이 종료됩니다.", "안내")
        } 
    }
}

$mainMenu = [System.Windows.Forms.MenuStrip]::new()
$infoMenu = [System.Windows.Forms.ToolStripMenuItem]::new()
$systemMenu = [System.Windows.Forms.ToolStripMenuItem]::new()
$appsView = [System.Windows.Forms.ListView]::new()
$appsDirectory = [System.IO.DirectoryInfo]::new((Get-Volume -FileSystemLabel $dataDrive).DriveLetter + ":\apps")
$internalAppsDirectory = [System.IO.DirectoryInfo]::new("%systemroot%\apps")
$infoMenu.Text = "정보"
$systemMenu.Text = "시스템"
$appsView.MultiSelect = $false
$appsView.Size = [System.Drawing.Size]::new(600, 300)
$appsView.Location = [System.Drawing.Point]::new(30, 30)
$notepad = [System.Windows.Forms.ListViewItem]::new("메모장")
$notepad.Tag = "notepad"
$initScript = [System.Windows.Forms.ListViewItem]::new("이미지 설치 스크립트")
$initScript.Tag = "initScript"
$appsView.Items.Add($notepad)
$appsView.Items.Add($initScript)
# 데이터 드라이브의 apps폴더에 있는 파일 불러오기
if ($null -ne $appsDirectory) {
    foreach ($file in $appsDirectory.GetFiles()) {
        $app = [System.Windows.Forms.ListViewItem]::new($file.Name)
        $app.Tag = $file.fullName
        $appsView.Items.Add($app)
    }
}
# boot.wim\windows\apps에 있는 파일 불러오기
if ($null -ne $internalAppsDirectory) {
    foreach ($file in $internalAppsDirectory.GetFiles()) {
        $app = [System.Windows.Forms.ListViewItem]::new($file.Name)
        $app.Tag = $file.fullName
        $appsView.Items.Add($app)
    }
}
$appsView.Add_DoubleClick({ appsClick -object $appsView })
$versionInfo = [System.Windows.Forms.ToolStripMenuItem]::new()
$shutdown = [System.Windows.Forms.ToolStripMenuItem]::new()
$reboot = [System.Windows.Forms.ToolStripMenuItem]::new()
$versionInfo.Text = "버전 정보: ${version}"
$shutdown.Text = "종료"
$shutdown.Add_Click({ systemManage })
$reboot.Text = "다시시작"
$reboot.Add_Click({ systemManage -isRestart $true })
$versionInfo.Add_Click({ versionInfoClick })
$infoMenu.DropDownItems.Add($versionInfo)
$systemMenu.DropDownItems.AddRange(@($shutdown, $reboot))
$mainMenu.Items.Add($infoMenu)
$mainMenu.Items.AddRange($systemMenu)

$main.Controls.Add($mainMenu)
$main.Controls.Add($appsView)
$main.MainMenuStrip = $mainMenu

$main.ShowDialog()