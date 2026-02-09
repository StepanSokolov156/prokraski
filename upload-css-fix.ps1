# Quick CSS upload
$ftpHost = "85.119.149.127"
$ftpUser = "vh11830"
$ftpPass = "62lSAm1r8u"
$localPath = "C:\Users\stepa\Desktop\prokraski.com"
$file = "catalog/view/theme/prostore/stylesheet/portfolio.css"
$localFile = Join-Path $localPath $file
$remoteFile = "/www/prokraski.com/" + $file.Replace('\', '/')

Write-Host "Uploading portfolio.css..." -ForegroundColor Cyan

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

    Write-Host "Successfully uploaded: portfolio.css" -ForegroundColor Green
    Write-Host ""
    Write-Host "Fix applied:" -ForegroundColor Yellow
    Write-Host "- Override theme's display: none for fancybox-caption" -ForegroundColor White
    Write-Host "- Added !important to force visibility" -ForegroundColor White
} catch {
    Write-Host "Failed: $($_.Exception.Message)" -ForegroundColor Red
}
