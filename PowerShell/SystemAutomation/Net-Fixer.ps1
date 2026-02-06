# Net-Fixer.ps1
# A "one-click" network troubleshooting and repair utility.

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "          NET-FIXER: Connection Repair         " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Requires Administrator privileges for some steps." -ForegroundColor Yellow

# OS Check
if (-not $IsWindows) {
    Write-Host "ERROR: This script is designed for Windows only." -ForegroundColor Red
    exit
}

# Check for Admin rights
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: Please run PowerShell as Administrator to use all repair features." -ForegroundColor Red
    # Continue anyway for non-admin steps, or could exit here
}

# Confirmation Prompt
$confirmation = Read-Host "This will temporarily disconnect your network. Continue? (y/n)"
if ($confirmation -ne 'y') {
    Write-Host "Aborted by user." -ForegroundColor Yellow
    exit
}

Write-Host "`n[1/5] Flushing DNS Cache..." -ForegroundColor Gray
ipconfig /flushdns | Out-Null
Write-Host "✓ Done." -ForegroundColor Green

Write-Host "[2/5] Releasing and Renewing IP Address..." -ForegroundColor Gray
ipconfig /release | Out-Null
ipconfig /renew | Out-Null
Write-Host "✓ Done." -ForegroundColor Green

Write-Host "[3/5] Resetting Winsock Catalog..." -ForegroundColor Gray
try {
    netsh winsock reset | Out-Null
    Write-Host "✓ Done." -ForegroundColor Green
} catch {
    Write-Host "✗ Failed (Requires Admin)." -ForegroundColor Red
}

Write-Host "[4/5] Resetting IP Stack..." -ForegroundColor Gray
try {
    netsh int ip reset | Out-Null
    Write-Host "✓ Done." -ForegroundColor Green
} catch {
    Write-Host "✗ Failed (Requires Admin)." -ForegroundColor Red
}

Write-Host "[5/5] Clearing ARP Cache..." -ForegroundColor Gray
try {
    arp -d * 2>$null
    Write-Host "✓ Done." -ForegroundColor Green
} catch {
    Write-Host "✗ Failed (Requires Admin)." -ForegroundColor Red
}

Write-Host "`n===============================================" -ForegroundColor Cyan
Write-Host "  Repair steps completed! Try your connection. " -ForegroundColor Cyan
Write-Host "  Note: A restart may be required for some fixes." -ForegroundColor White
Write-Host "===============================================" -ForegroundColor Cyan
pause
