# Test FTP Upload
$ftpHost = "85.119.149.127"
$ftpUser = "vh11830"
$ftpPass = "62lSAm1r8u"

Write-Host "Testing FTP Upload..." -ForegroundColor Green
Write-Host ""

# Create test file
$testFile = "C:\Users\stepa\Desktop\prokraski.com\test_upload.txt"
"Test file created at $(Get-Date)" | Out-File -FilePath $testFile

try {
    # Upload test file
    $uri = "ftp://${ftpHost}/www/prokraski.com/test_upload.txt"
    $ftp = [System.Net.FtpWebRequest]::Create($uri)
    $ftp.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $ftp.UseBinary = $true
    $ftp.KeepAlive = $false

    $content = [System.IO.File]::ReadAllBytes($testFile)
    $requestStream = $ftp.GetRequestStream()
    $requestStream.Write($content, 0, $content.Length)
    $requestStream.Close()

    $response = $ftp.GetResponse()
    $response.Close()

    Write-Host "Test file uploaded successfully!" -ForegroundColor Green

    # Verify by listing files
    $uri = "ftp://${ftpHost}/www/prokraski.com/"
    $ftp = [System.Net.FtpWebRequest]::Create($uri)
    $ftp.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
    $ftp.KeepAlive = $false

    $response = $ftp.GetResponse()
    $stream = $response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)

    Write-Host ""
    Write-Host "Files in directory (test_upload.txt should be there):" -ForegroundColor Cyan
    while (-not $reader.EndOfStream) {
        $file = $reader.ReadLine()
        if ($file -eq "test_upload.txt") {
            Write-Host "  $file - FOUND!" -ForegroundColor Green
        } else {
            Write-Host "  $file"
        }
    }

    $reader.Close()
    $response.Close()

    # Clean up test file
    Remove-Item $testFile -Force
    Write-Host ""
    Write-Host "Local test file deleted." -ForegroundColor Yellow

} catch {
    Write-Host "FTP Upload FAILED:" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Details:" -ForegroundColor Yellow
    Write-Host "  $($_.Exception.ToString())" -ForegroundColor Yellow
}
