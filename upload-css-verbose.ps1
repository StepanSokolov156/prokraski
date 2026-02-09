# Upload single CSS file
$ftpHost = "85.119.149.127"
$ftpUser = "vh11830"
$ftpPass = "62lSAm1r8u"
$remotePath = "/www/prokraski.com/"
$localPath = "C:\Users\stepa\Desktop\prokraski.com"

$file = "catalog/view/theme/prostore/stylesheet/portfolio.css"
$localFile = Join-Path $localPath $file
$remoteFile = $remotePath + $file.Replace('\', '/')

Write-Host "Attempting to upload: $file" -ForegroundColor Cyan
Write-Host "Local: $localFile" -ForegroundColor DarkGray
Write-Host "Remote: $remoteFile" -ForegroundColor DarkGray
Write-Host ""

# Try different approach - check if directory exists first
$remoteDir = [System.IO.Path]::GetDirectoryName($remoteFile)
Write-Host "Checking directory: $remoteDir" -ForegroundColor Yellow

try {
    # List directory to check if it exists
    $listUri = "ftp://${ftpHost}${remoteDir}"
    $listFtp = [System.Net.FtpWebRequest]::Create($listUri)
    $listFtp.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    $listFtp.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
    $listFtp.KeepAlive = $false
    $listFtp.UseBinary = $true

    try {
        $listResponse = $listFtp.GetResponse()
        $listStream = $listResponse.GetResponseStream()
        $listReader = New-Object System.IO.StreamReader($listStream)

        Write-Host "Directory contents:" -ForegroundColor Green
        while (-not $listReader.EndOfStream) {
            Write-Host "  " + $listReader.ReadLine() -ForegroundColor DarkGray
        }

        $listReader.Close()
        $listResponse.Close()
    } catch {
        Write-Host "Directory check failed: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Try to create directory
    Write-Host "Creating directory..." -ForegroundColor Yellow
    try {
        $dirFtp = [System.Net.FtpWebRequest]::Create($listUri)
        $dirFtp.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
        $dirFtp.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
        $dirFtp.KeepAlive = $false
        $dirFtp.GetResponse().Close()
        Write-Host "Directory created or already exists" -ForegroundColor Green
    } catch {
        Write-Host "Directory creation result: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    # Upload file with full path
    Write-Host "Uploading file..." -ForegroundColor Yellow
    $uri = "ftp://${ftpHost}${remoteFile}"
    $ftp = [System.Net.FtpWebRequest]::Create($uri)
    $ftp.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $ftp.UseBinary = $true
    $ftp.KeepAlive = $false

    $content = [System.IO.File]::ReadAllBytes($localFile)
    Write-Host "File size: $($content.Length) bytes" -ForegroundColor DarkGray

    $requestStream = $ftp.GetRequestStream()
    $requestStream.Write($content, 0, $content.Length)
    $requestStream.Close()
    $response = $ftp.GetResponse()
    $response.Close()

    Write-Host "Successfully uploaded: $file" -ForegroundColor Green

} catch {
    Write-Host "Upload failed:" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor DarkRed

    # Show detailed error
    if ($_.Exception.InnerException) {
        Write-Host "  Inner: $($_.Exception.InnerException.Message)" -ForegroundColor DarkRed
    }

    Write-Host ""
    Write-Host "Possible solutions:" -ForegroundColor Yellow
    Write-Host "1. Upload manually via FileZilla to: catalog/view/theme/prostore/stylesheet/" -ForegroundColor White
    Write-Host "2. Check directory permissions on server" -ForegroundColor White
    Write-Host "3. The stylesheet directory may not exist" -ForegroundColor White
}
