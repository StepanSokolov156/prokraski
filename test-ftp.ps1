# Test FTP Connection
$ftpHost = "85.119.149.127"
$ftpUser = "vh11830"
$ftpPass = "62lSAm1r8u"

Write-Host "Testing FTP connection to $ftpHost..." -ForegroundColor Green
Write-Host "User: $ftpUser" -ForegroundColor Cyan
Write-Host ""

try {
    # Try to list files
    $uri = "ftp://${ftpHost}/www/prokraski.com/"
    $ftp = [System.Net.FtpWebRequest]::Create($uri)
    $ftp.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
    $ftp.KeepAlive = $false

    $response = $ftp.GetResponse()
    $stream = $response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)

    Write-Host "FTP Connection SUCCESS!" -ForegroundColor Green
    Write-Host "Files in www/prokraski.com/:" -ForegroundColor Cyan
    Write-Host ""

    while (-not $reader.EndOfStream) {
        Write-Host "  " + $reader.ReadLine()
    }

    $reader.Close()
    $response.Close()

    Write-Host ""
    Write-Host "Connection test completed successfully!" -ForegroundColor Green

} catch {
    Write-Host "FTP Connection FAILED:" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Details:" -ForegroundColor Yellow
    Write-Host "  $($_.Exception.ToString())" -ForegroundColor Yellow
}
