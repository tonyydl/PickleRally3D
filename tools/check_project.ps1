param([string]$Godot = 'godot')

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$logDirectory = Join-Path $projectRoot '.tools/validation'
New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
$executable = (Get-Command $Godot -ErrorAction Stop).Source

function Invoke-Check([string]$Name, [string[]]$GodotArguments, [bool]$RequirePass = $false) {
    $logPath = Join-Path $logDirectory "$Name.log"
    $output = & $executable --headless --path $projectRoot --log-file $logPath @GodotArguments 2>&1 | Out-String
    $code = $LASTEXITCODE
    if ($code -ne 0 -or $output -match '(?m)(SCRIPT ERROR:|ERROR:|WARNING:)' -or ($RequirePass -and $output -notmatch 'PASS:')) {
        Write-Output $output
        throw "$Name failed (exit=$code). See $logPath"
    }
    Write-Output "PASS: $Name"
    if ($RequirePass) { Write-Output $output.Trim() }
}

Invoke-Check 'import' @('--editor', '--quit')
foreach ($test in @('flight', 'rules', 'shots', 'match', 'controls', 'shot_controls', 'web_performance')) {
    Invoke-Check $test @('--script', "res://tests/test_$test.gd") $true
}
Invoke-Check 'startup' @('--quit-after', '30')
Write-Output "All checks passed. Logs: $logDirectory"
