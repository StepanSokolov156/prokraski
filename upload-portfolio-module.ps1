# Upload Portfolio Module Files to FTP
# Загружает только файлы модуля "Наши работы"

$ftpHost = "85.119.149.127"
$ftpUser = "vh11830"
$ftpPass = "62lSAm1r8u"
$remotePath = "/www/prokraski.com/"
$localPath = "C:\Users\stepa\Desktop\prokraski.com"

# Portfolio module files to upload
$portfolioFiles = @(
    # Admin controllers
    "admin/controller/extension/module/prostore_portfolio.php",
    "admin/controller/extension/module/prostore/prostore_portfolio.php",

    # Admin model
    "admin/model/extension/theme/prostoreportfolio.php",

    # Admin language files
    "admin/language/ru-ru/extension/module/prostore_portfolio.php",
    "admin/language/ru-ru/extension/module/prostore/prostore_portfolio.php",
    "admin/language/en-gb/extension/module/prostore_portfolio.php",
    "admin/language/en-gb/extension/module/prostore/prostore_portfolio.php",

    # Admin templates
    "admin/view/template/extension/module/prostore_portfolio.twig",
    "admin/view/template/extension/module/prostorecatalog/prostore_portfolio_form.twig",
    "admin/view/template/extension/module/prostorecatalog/prostore_portfolio_list.twig",

    # Catalog controller
    "catalog/controller/extension/module/prostore_portfolio.php",

    # Catalog model
    "catalog/model/extension/module/prostoreportfolio.php",

    # Catalog language files
    "catalog/language/ru-ru/extension/module/prostore_portfolio.php",
    "catalog/language/en-gb/extension/module/prostore_portfolio.php",

    # Catalog templates
    "catalog/view/theme/prostore/template/extension/module/prostore_portfolio.twig",
    "catalog/view/theme/prostore/template/extension/module/prostore_portfolio_list.twig",

    # Catalog CSS
    "catalog/view/theme/prostore/stylesheet/portfolio.css"
)

Write-Host "Portfolio Module Upload Script" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host ""
Write-Host "This will upload the Portfolio module files to the server." -ForegroundColor Cyan
Write-Host ""

$uploaded = 0
$failed = 0

foreach ($file in $portfolioFiles) {
    $localFile = Join-Path $localPath $file

    # Check if file exists
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
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Go to Admin Panel -> Extensions -> Modules" -ForegroundColor White
Write-Host "2. Find 'Portfolio' module and click Install" -ForegroundColor White
Write-Host "3. Edit module settings" -ForegroundColor White
Write-Host "4. Add to Design -> Layouts" -ForegroundColor White
Write-Host "5. Add portfolio items via Catalog -> Portfolio" -ForegroundColor White
Write-Host ""
