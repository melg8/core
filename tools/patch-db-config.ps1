param(
    [Parameter(Mandatory = $true)][string]$MangosdConf,
    [Parameter(Mandatory = $true)][string]$RealmdConf,
    [Parameter(Mandatory = $true)][string]$HostName,
    [Parameter(Mandatory = $true)][int]$Port,
    [Parameter(Mandatory = $true)][string]$User,
    [AllowEmptyString()][string]$Password = '',
    [string]$Address = '127.0.0.1',
    [int]$WorldPort = 8085
)

$ErrorActionPreference = 'Stop'

function Set-KeyValue {
    param(
        [string]$Path,
        [string]$Key,
        [string]$Value,
        [switch]$Raw
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "File not found: $Path"
    }

    $text = [System.IO.File]::ReadAllText($Path)
    $replacement = if ($Raw) { $Value } else { '"' + $Value + '"' }
    $pattern = '(?m)^([ \t]*' + [regex]::Escape($Key) + '[ \t]*=[ \t]*)[^\r\n]*'
    $rx = [regex]::new($pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)

    if ($rx.IsMatch($text)) {
        $text = $rx.Replace($text, [System.Text.RegularExpressions.MatchEvaluator] { param($m) $m.Groups[1].Value + $replacement }, 1)
    }
    else {
        $text = $text.TrimEnd() + "`r`n" + $Key + ' = ' + $replacement + "`r`n"
    }

    [System.IO.File]::WriteAllText($Path, $text, (New-Object System.Text.UTF8Encoding($false)))
}

$login = "$HostName;$Port;$User;$Password;realmd"

Set-KeyValue -Path $MangosdConf -Key 'LoginDatabase.Info'     -Value $login
Set-KeyValue -Path $MangosdConf -Key 'WorldDatabase.Info'     -Value "$HostName;$Port;$User;$Password;mangos"
Set-KeyValue -Path $MangosdConf -Key 'CharacterDatabase.Info' -Value "$HostName;$Port;$User;$Password;characters"
Set-KeyValue -Path $MangosdConf -Key 'LogsDatabase.Info'      -Value "$HostName;$Port;$User;$Password;logs"

Set-KeyValue -Path $RealmdConf -Key 'LoginDatabaseInfo' -Value $login
# Keep the version check relaxed: it allows modified clients (e.g. d3d8to9).
Set-KeyValue -Path $RealmdConf -Key 'StrictVersionCheck' -Value '0' -Raw

Write-Host ("  - database connections: {0};{1};{2};***" -f $HostName, $Port, $User)
Write-Host ("  - realm address: {0}, world port: {1}" -f $Address, $WorldPort)
