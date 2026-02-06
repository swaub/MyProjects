# Wifi-Revealer.ps1
# Retrieves saved Wi-Fi profiles and their passwords.

$ErrorActionPreference = "SilentlyContinue"

Write-Host "--- Saved Wi-Fi Passwords ---" -ForegroundColor Cyan

$profiles = netsh wlan show profiles | Select-String "All User Profile"

if (-not $profiles) {
    Write-Host "No Wi-Fi profiles found." -ForegroundColor Yellow
    exit
}

foreach ($profile in $profiles) {
    $profileName = $profile.ToString().Split(":")[1].Trim()
    
    $details = netsh wlan show profile name="$profileName" key=clear
    $passLine = $details | Select-String "Key Content"
    
    if ($passLine) {
        $password = $passLine.ToString().Split(":")[1].Trim()
    } else {
        $password = "[No Password / Enterprise]"
    }

    $output = "{0,-30} : {1}" -f $profileName, $password
    Write-Host $output
}

Write-Host "`n-----------------------------" -ForegroundColor Cyan
pause
