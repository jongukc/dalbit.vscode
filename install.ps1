$ErrorActionPreference = "Stop"

$ExtName = "jongukc.dalbit-0.1.0"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Detect extensions directory
$ExtDir = Join-Path $env:USERPROFILE ".vscode\extensions"
if (-not (Test-Path $ExtDir)) {
    $ExtDir = Join-Path $env:USERPROFILE ".vscode-server\extensions"
    if (-not (Test-Path $ExtDir)) {
        Write-Error "Could not find VS Code extensions directory"
        exit 1
    }
}

$Target = Join-Path $ExtDir $ExtName

if (Test-Path $Target) {
    Write-Host "removing existing $Target"
    Remove-Item -Recurse -Force $Target
}

# Create directory junction (works without admin)
New-Item -ItemType Junction -Path $Target -Target $ScriptDir | Out-Null
Write-Host "installed: $Target -> $ScriptDir"
Write-Host ""
Write-Host "restart VS Code, then:"
Write-Host "  Ctrl+Shift+P -> Preferences: Color Theme -> dalbit"
