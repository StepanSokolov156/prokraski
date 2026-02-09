# Retry failed Portfolio module files
$ftpHost = "85.119.149.127"
$ftpUser = "vh11830"
$ftpPass = "62lSAm1r8u"
$remotePath = "/www/prokraski.com/"
$localPath = "C:\Users\stepa\Desktop\prokraski.com"

# Files that failed to upload
$failedFiles = @(
    "catalog/model/extension/module/prostoreportfolio.php",
    "catalog/language/ru-ru/extension/module/prostore_portfolio.php",
    "catalog/language/en-gb/extension/module/prostore_portfolio.php",
    "catalog/view/theme/prostore/stylesheet/portfolio.css"
)

Write-Host "Retrying failed files..." -ForegroundColor Yellow
Write-Host ""

$uploaded = 0
$failed = 0

foreach ($file in $failedFiles) {
    $localFile = Join-Path $localPath $file

    if (-not (Test-Path $localFile)) {
        Write-Host "Not found: $file" -ForegroundColor Red
        continue
    }

    $remoteFile = $remotePath + $file.Replace('\', '/')

    try {
        # Create remote directory if needed
        $remoteDir = [System.IO.Path]::GetDirectoryName($remoteFile)
        $dirUri = "ftp://${ftpHost}${remoteDir}"
        try {
            $dirFtp = [System.Net.FtpWebRequest]::Create($dirUri)
            $dirFtp.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
            $dirFtp.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
            $dirFtp.KeepAlive = $false
            $dirFtp.GetResponse().Close()
        } catch {
            # Directory might already exist
        }

        # Upload file
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
        Write-Host "Failed: $file" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor DarkRed
        $failed++
    }
}

Write-Host ""
Write-Host "Retry completed:" -ForegroundColor Cyan
Write-Host "  Uploaded: $uploaded files" -ForegroundColor Green
Write-Host "  Failed: $failed files" -ForegroundColor Red
