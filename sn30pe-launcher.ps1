$version = "0.1b"
Add-Type -AssemblyName System.Windows.Forms
$main = [System.Windows.Forms.Form]::new()
$main.Size = [System.Drawing.Size]::new(700, 400)
$main.Text = "앱 런처"

function versionInfoClick ($object, $eventArg) {
    [System.Windows.Forms.MessageBox]::Show("현재 버전은 ${version}입니다.", "버전 정보")
}

function appsClick ($object, $eventArg) {
    notepad.exe
}

function systemManage ($object, $eventArg, [bool]$isRestart) {
    if ($isRestart) {
        if ([System.Windows.Forms.MessageBox]::Show("시스템을 다시시작하시겠습니까?", "다시시작", [System.Windows.Forms.MessageBoxButtons]::OKCancel) -eq "OK") {
            Restart-Computer
        }
    }
    else {
        if ([System.Windows.Forms.MessageBox]::Show("시스템을 종료하시겠습니까?", "시스템 종료", [System.Windows.Forms.MessageBoxButtons]::OKCancel) -eq "OK") {
            Stop-Computer
        } 
    }
}

$mainMenu = [System.Windows.Forms.MenuStrip]::new()
$infoMenu = [System.Windows.Forms.ToolStripMenuItem]::new()
$systemMenu = [System.Windows.Forms.ToolStripMenuItem]::new()
$appsView = [System.Windows.Forms.ListView]::new()

$infoMenu.Text = "정보"
$systemMenu.Text = "시스템"
$appsView.Size = [System.Drawing.Size]::new(600, 300)
$appsView.Location = [System.Drawing.Point]::new(30, 30)
$notepad = [System.Windows.Forms.ListViewItem]::new("메모장")
$notepad.Tag = "notepad"
$appsView.Items.Add($notepad)
$appsView.Add_DoubleClick({ appsClick $appsView, $e })
$versionInfo = [System.Windows.Forms.ToolStripMenuItem]::new()
$shutdown = [System.Windows.Forms.ToolStripMenuItem]::new()
$reboot = [System.Windows.Forms.ToolStripMenuItem]::new()
$versionInfo.Text = "버전 정보: ${version}"
$shutdown.Text = "종료"
$shutdown.Add_Click({ systemManage })
$reboot.Text = "다시시작"
$reboot.Add_Click({ systemManage -isRestart $true })
$versionInfo.Add_Click({ versionInfoClick })
$shutdown.Add_Click({ systemManage -isRestart $false })
$infoMenu.DropDownItems.Add($versionInfo)
$systemMenu.DropDownItems.AddRange(@($shutdown, $reboot))
$mainMenu.Items.Add($infoMenu)
$mainMenu.Items.AddRange($systemMenu)

$main.Controls.Add($mainMenu)
$main.Controls.Add($appsView)
$main.MainMenuStrip = $mainMenu

$main.ShowDialog()