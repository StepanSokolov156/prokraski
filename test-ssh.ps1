# Test SSH connection using plink (PuTTY) or SSH.NET

# Try using plink from PuTTY if available
$plinkPath = "C:\Program Files\PuTTY\plink.exe"

if (Test-Path $plinkPath) {
    Write-Host "Using plink for SSH connection..." -ForegroundColor Green

$sshHost = "85.119.149.127"
    $user = "vh11830"
    $password = "62lSAm1r8u"
    $command = "pwd && ls -la www/prokraski.com"

    $output = & $plinkPath -ssh -batch -pw $password "$user@$sshHost" $command 2>&1
    Write-Host $output
} else {
    Write-Host "Plink not found at: $plinkPath" -ForegroundColor Yellow
    Write-Host "Please install PuTTY or use another SSH client" -ForegroundColor Yellow
}
