$version = "0.3b"
$dataDrive = "sn30-pe-data"
Add-Type -AssemblyName System.Windows.Forms
$main = [System.Windows.Forms.Form]::new()
$main.Size = [System.Drawing.Size]::new(700, 400)
$main.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$main.Text = "�� ��ó"

function versionInfoClick ($object, $eventArg) {
    [System.Windows.Forms.MessageBox]::Show("���� ������ ${version}�Դϴ�.`r������ ������ ����̺� ��ġ: $dataDrive", "���� ����")
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
        if ([System.Windows.Forms.MessageBox]::Show("�ý����� �ٽý����Ͻðڽ��ϱ�?", "�ٽý���", [System.Windows.Forms.MessageBoxButtons]::OKCancel) -eq "OK") {
            Restart-Computer
            [System.Windows.Forms.MessageBox]::Show("����� �ý����� �ٽý��۵˴ϴ�.", "�ȳ�")
        }
    }
    else {
        if ([System.Windows.Forms.MessageBox]::Show("�ý����� �����Ͻðڽ��ϱ�?", "�ý��� ����", [System.Windows.Forms.MessageBoxButtons]::OKCancel) -eq "OK") {
            Stop-Computer
            [System.Windows.Forms.MessageBox]::Show("����� �ý����� ����˴ϴ�.", "�ȳ�")
        } 
    }
}

$mainMenu = [System.Windows.Forms.MenuStrip]::new()
$infoMenu = [System.Windows.Forms.ToolStripMenuItem]::new()
$systemMenu = [System.Windows.Forms.ToolStripMenuItem]::new()
$appsView = [System.Windows.Forms.ListView]::new()
$appsDirectory = [System.IO.DirectoryInfo]::new((Get-Volume -FileSystemLabel $dataDrive).DriveLetter + ":\apps")
$internalAppsDirectory = [System.IO.DirectoryInfo]::new("%systemroot%\apps")
$infoMenu.Text = "����"
$systemMenu.Text = "�ý���"
$appsView.MultiSelect = $false
$appsView.Size = [System.Drawing.Size]::new(600, 300)
$appsView.Location = [System.Drawing.Point]::new(30, 30)
$notepad = [System.Windows.Forms.ListViewItem]::new("�޸���")
$notepad.Tag = "notepad"
$initScript = [System.Windows.Forms.ListViewItem]::new("�̹��� ��ġ ��ũ��Ʈ")
$initScript.Tag = "initScript"
$appsView.Items.Add($notepad)
$appsView.Items.Add($initScript)
# ������ ����̺��� apps������ �ִ� ���� �ҷ�����
if ($null -ne $appsDirectory) {
    foreach ($file in $appsDirectory.GetFiles()) {
        $app = [System.Windows.Forms.ListViewItem]::new($file.Name)
        $app.Tag = $file.fullName
        $appsView.Items.Add($app)
    }
}
# boot.wim\windows\apps�� �ִ� ���� �ҷ�����
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
$versionInfo.Text = "���� ����: ${version}"
$shutdown.Text = "����"
$shutdown.Add_Click({ systemManage })
$reboot.Text = "�ٽý���"
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