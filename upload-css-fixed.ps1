# Upload CSS file - Fixed path
$ftpHost = "85.119.149.127"
$ftpUser = "vh11830"
$ftpPass = "62lSAm1r8u"
$localPath = "C:\Users\stepa\Desktop\prokraski.com"

$file = "catalog/view/theme/prostore/stylesheet/portfolio.css"
$localFile = Join-Path $localPath $file

# Fix remote path - replace backslashes
$remoteFile = "/www/prokraski.com/catalog/view/theme/prostore/stylesheet/portfolio.css"

Write-Host "Uploading: portfolio.css" -ForegroundColor Cyan
Write-Host ""

try {
    # Create stylesheet directory
    $dirUri = "ftp://${ftpHost}/www/prokraski.com/catalog/view/theme/prostore/stylesheet"
    try {
        $dirFtp = [System.Net.FtpWebRequest]::Create($dirUri)
        $dirFtp.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
        $dirFtp.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
        $dirFtp.KeepAlive = $false
        $dirFtp.GetResponse().Close()
    } catch {
        # Directory may already exist
    }

    # Upload file
    $uri = "ftp://${ftpHost}/www/prokraski.com/catalog/view/theme/prostore/stylesheet/portfolio.css"
    $ftp = [System.Net.FtpWebRequest]::Create($uri)
    $ftp.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $ftp.UseBinary = $true
    $ftp.KeepAlive = $false

    $content = [System.IO.File]::ReadAllBytes($localFile)
    $requestStream = $ftp.GetRequestStream()
    $requestStream.Write($content, 0, $content.Length)
    $requestStream.Close()
    $response = $ftp.GetResponse()
    $response.Close()

    Write-Host "Successfully uploaded: portfolio.css" -ForegroundColor Green

} catch {
    Write-Host "Upload failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please upload this file manually via FileZilla:" -ForegroundColor Yellow
    Write-Host "  Local: $localFile" -ForegroundColor White
    Write-Host "  Remote: catalog/view/theme/prostore/stylesheet/" -ForegroundColor White
}
