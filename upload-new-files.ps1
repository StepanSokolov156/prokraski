# FTP Upload Script for NEW files only (after module development)
# Uploads only files created after initial git commit

$ftpHost = "85.119.149.127"
$ftpUser = "vh11830"
$ftpPass = "62lSAm1r8u"
$remotePath = "/www/prokraski.com/"
$localPath = "C:\Users\stepa\Desktop\prokraski.com"

# Files to exclude from upload
$excludePatterns = @(
    ".git\",
    ".gitignore",
    ".claude\",
    "node_modules\",
    "system\storage\cache\",
    "system\storage\logs\",
    "system\storage\session\",
    "image\cache\",
    "image\achewebp\",
    "config.php",
    "admin\config.php",
    "*.bak",
    "*.sql",
    "PLAN_PORTFOLIO_MODULE.md",
    "upload-*.ps1",
    "test-*.ps1"
)

# Get files created after initial commit (module files only)
git log --reverse --format="%H" --max-count=1 | ForEach-Object {
    $initialCommit = $_
    $newFiles = git diff --name-only $initialCommit HEAD 2>$null

    if ($newFiles) {
        Write-Host "Files to upload (new/modified since initial commit):" -ForegroundColor Cyan
        Write-Host ""

        $uploaded = 0
        $failed = 0

        foreach ($file in $newFiles) {
            $localFile = Join-Path $localPath $file

            # Skip if excluded
            $shouldExclude = $false
            foreach ($pattern in $excludePatterns) {
                if ($file -like "*$pattern*") {
                    $shouldExclude = $true
                    break
                }
            }

            if ($shouldExclude) {
                Write-Host "Skipping: $file" -ForegroundColor DarkGray
                continue
            }

            # Check if file exists (might be deleted)
            if (-not (Test-Path $localFile)) {
                Write-Host "Not found: $file" -ForegroundColor Yellow
                continue
            }

            # Skip directories
            if (Test-Path $localFile -PathType Container) {
                continue
            }

            # Upload file
            $remoteFile = $remotePath + $file.Replace('\', '/')

            try {
                $uri = "ftp://${ftpHost}${remoteFile}"
                $ftp = [System.Net.FtpWebRequest]::Create($uri)
                $ftp.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
                $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
                $ftp.UseBinary = $true
                $ftp.KeepAlive = $false

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
        Write-Host "Upload completed:" -ForegroundColor Green
        Write-Host "  Uploaded: $uploaded files" -ForegroundColor Green
        if ($failed -gt 0) {
            Write-Host "  Failed: $failed files" -ForegroundColor Red
        }
    } else {
        Write-Host "No new files to upload." -ForegroundColor Yellow
    }
}
