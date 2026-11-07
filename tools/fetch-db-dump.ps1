param(
    [Parameter(Mandatory = $true)][string]$DestDir
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
New-Item -ItemType Directory -Force -Path $DestDir | Out-Null

$headers = @{ 'User-Agent' = 'vmangos-local-setup' }
try {
    $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/vmangos/core/releases/tags/db_latest' -Headers $headers
}
catch {
    throw "Could not query GitHub for the db_latest release: $($_.Exception.Message)"
}

$asset = $release.assets |
    Where-Object { $_.name -like 'db-*.zip' -and $_.name -notlike 'db-sqlite-*' } |
    Select-Object -First 1

if (-not $asset) {
    throw 'The db_latest release does not contain a MySQL dump asset.'
}

$zip = Join-Path $DestDir $asset.name
Write-Host ("Downloading {0} ({1:N1} MB) ..." -f $asset.name, ($asset.size / 1MB))
& curl.exe -L --fail --retry 3 --progress-bar -o $zip $asset.browser_download_url
if ($LASTEXITCODE -ne 0) {
    throw "Download failed (curl exit code $LASTEXITCODE)."
}

Write-Host 'Extracting ...'
$tar = Join-Path $env:SystemRoot 'System32\tar.exe'
if (Test-Path -LiteralPath $tar) {
    & $tar -xf $zip -C $DestDir
    if ($LASTEXITCODE -ne 0) {
        throw "Extraction failed (tar exit code $LASTEXITCODE)."
    }
}
else {
    Expand-Archive -LiteralPath $zip -DestinationPath $DestDir -Force
}

$dumpDir = Join-Path $DestDir 'mysql-dump'
if (Test-Path -LiteralPath $dumpDir) {
    Get-ChildItem -LiteralPath $dumpDir -Filter '*.sql' | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $DestDir $_.Name) -Force
    }
    Remove-Item -LiteralPath $dumpDir -Recurse -Force -ErrorAction SilentlyContinue
}

Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue

foreach ($name in 'logon.sql', 'mangos.sql', 'characters.sql', 'logs.sql') {
    if (-not (Test-Path -LiteralPath (Join-Path $DestDir $name))) {
        throw "Missing $name after extraction."
    }
}

Write-Host 'Database dumps are ready.'
