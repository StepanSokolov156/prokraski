# Upload updated Portfolio files (image sizing fix)
$ftpHost = "85.119.149.127"
$ftpUser = "vh11830"
$ftpPass = "62lSAm1r8u"
$localPath = "C:\Users\stepa\Desktop\prokraski.com"

$files = @(
    "catalog/controller/extension/module/prostore_portfolio.php",
    "catalog/view/theme/prostore/stylesheet/portfolio.css"
)

Write-Host "Uploading updated Portfolio files..." -ForegroundColor Cyan
Write-Host ""

$uploaded = 0
$failed = 0

foreach ($file in $files) {
    $localFile = Join-Path $localPath $file

    if (-not (Test-Path $localFile)) {
        Write-Host "Not found: $file" -ForegroundColor Red
        continue
    }

    # Build remote path
    $remoteFile = "/www/prokraski.com/" + $file.Replace('\', '/')

    try {
        $uri = "ftp://${ftpHost}${remoteFile}"
        $ftp = [System.Net.FtpWebRequest]::Create($uri)
        $ftp.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
        $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
        $ftp.UseBinary = $true
        $ftp.KeepAlive = $false

        $content = [System.IO.File]::ReadAllBytes($localFile)
        $requestStream = $ftp.GetRequestStream()
        $requestStream.Write($content, 0, $content.Length)
        $requestStream.Close()
        $ftp.GetResponse().Close()

        Write-Host "Uploaded: $file" -ForegroundColor Green
        $uploaded++
    } catch {
        Write-Host "Failed: $file - $($_.Exception.Message)" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
Write-Host "Upload completed: $uploaded uploaded, $failed failed" -ForegroundColor Cyan
Write-Host ""
Write-Host "Changes:" -ForegroundColor Yellow
Write-Host "- Fixed height (300px) for all portfolio images" -ForegroundColor White
Write-Host "- Images maintain aspect ratio with object-fit: cover" -ForegroundColor White
Write-Host "- Center crop (object-position: center)" -ForegroundColor White
