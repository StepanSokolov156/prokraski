# FTP Upload Script for prokraski.com
# Usage: .\upload-ftp.ps1

$ftpHost = "85.119.149.127"
$ftpUser = "vh11830"
$ftpPass = "62lSAm1r8u"
$remotePath = "/www/prokraski.com/"
$localPath = "C:\Users\stepa\Desktop\prokraski.com"

# Files to exclude from upload
$excludePatterns = @(
    ".git\",
    ".gitignore",
    "node_modules\",
    "system\storage\cache\",
    "system\storage\logs\",
    "system\storage\session\",
    "image\cache\",
    "config.php",
    "admin\config.php",
    "*.bak",
    "*.sql",
    "upload-ftp.ps1"
)

Write-Host "FTP Upload Script for prokraski.com" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""

# Check if local path exists
if (-not (Test-Path $localPath)) {
    Write-Host "Error: Local path not found: $localPath" -ForegroundColor Red
    exit 1
}

function UploadFile($localFile, $remoteFile) {
    try {
        $uri = "ftp://${ftpHost}${remoteFile}"
        $ftp = [System.Net.FtpWebRequest]::Create($uri)
        $ftp.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
        $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
        $ftp.UseBinary = $true
        $ftp.KeepAlive = $false

        $content = [System.IO.File]::ReadAllBytes($localFile)
        $ftp.GetRequestStream().Write($content, 0, $content.Length)

        Write-Host "Uploaded: $localFile -> $remoteFile" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Error uploading $localFile`: $_" -ForegroundColor Red
        return $false
    }
}

function CreateFtpDirectory($remoteDir) {
    try {
        $uri = "ftp://${ftpHost}${remoteDir}"
        $ftp = [System.Net.FtpWebRequest]::Create($uri)
        $ftp.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
        $ftp.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
        $ftp.KeepAlive = $false
        $response = $ftp.GetResponse()
        $response.Close()
        return $true
    } catch {
        # Directory might already exist
        return $true
    }
}

function ShouldExclude($file) {
    foreach ($pattern in $excludePatterns) {
        if ($file -like "*$pattern*") {
            return $true
        }
    }
    return $false
}

# Get all files recursively
$files = Get-ChildItem -Path $localPath -Recurse -File | Where-Object { -not (ShouldExclude $_.FullName) }

Write-Host "Found $($files.Count) files to upload" -ForegroundColor Cyan
Write-Host ""

$uploaded = 0
$failed = 0

foreach ($file in $files) {
    $relativePath = $file.FullName.Substring($localPath.Length).Replace('\', '/')
    $remoteFile = $remotePath + $relativePath

    # Create remote directory if needed
    $remoteDir = [System.IO.Path]::GetDirectoryName($remoteFile)
    CreateFtpDirectory $remoteDir

    if (UploadFile $file.FullName $remoteFile) {
        $uploaded++
    } else {
        $failed++
    }
}

Write-Host ""
Write-Host "Upload completed:" -ForegroundColor Green
Write-Host "  Uploaded: $uploaded files" -ForegroundColor Green
if ($failed -gt 0) {
    Write-Host "  Failed: $failed files" -ForegroundColor Red
}
