param(
    [ValidateSet('All', 'Windows', 'Web')][string]$Target = 'All',
    [string]$Godot = 'godot'
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$executable = (Get-Command $Godot -ErrorAction Stop).Source
$buildDirectory = Join-Path $projectRoot 'builds'
$logDirectory = Join-Path $projectRoot '.tools/export'
New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
New-Item -ItemType Directory -Path $buildDirectory -Force | Out-Null
if (-not (Test-Path -LiteralPath (Join-Path $buildDirectory '.gdignore'))) {
    New-Item -ItemType File -Path (Join-Path $buildDirectory '.gdignore') | Out-Null
}

function Export-Game([string]$Preset, [string]$Folder, [string]$Filename) {
    $destination = Join-Path $buildDirectory $Folder
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    $logPath = Join-Path $logDirectory "$Folder.log"
    $output = & $executable --headless --path $projectRoot --log-file $logPath --export-release $Preset (Join-Path $destination $Filename) 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0 -or $output -match '(?m)(SCRIPT ERROR:|ERROR:|WARNING:)') {
        Write-Output $output
        throw "Export failed: $Preset. See $logPath"
    }
    Copy-Item -LiteralPath (Join-Path $projectRoot 'docs/distribution/GODOT_LICENSE.txt') -Destination $destination -Force
    Copy-Item -LiteralPath (Join-Path $projectRoot 'docs/distribution/GODOT_COPYRIGHT.txt') -Destination $destination -Force
    Copy-Item -LiteralPath (Join-Path $projectRoot 'assets/fonts/OFL.txt') -Destination (Join-Path $destination 'NOTO_FONT_LICENSE.txt') -Force
    $readme = if ($Folder -eq 'windows') { 'WINDOWS_README.txt' } else { 'WEB_README.txt' }
    Copy-Item -LiteralPath (Join-Path $projectRoot "docs/distribution/$readme") -Destination (Join-Path $destination 'README.txt') -Force
    $archive = Join-Path $buildDirectory "PickleRally3D-$Folder.zip"
    Compress-Archive -Path (Join-Path $destination '*') -DestinationPath $archive -Force
    Write-Output "PASS: $Preset -> $destination"
    Write-Output "Archive: $archive"
}

if ($Target -in @('All', 'Windows')) {
    Export-Game 'Windows Desktop' 'windows' 'PickleRally3D.exe'
}
if ($Target -in @('All', 'Web')) {
    Export-Game 'Web' 'web' 'index.html'
}
