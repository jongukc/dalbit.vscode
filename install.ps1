$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Vsix = Join-Path $ScriptDir "dalbit.vsix"

Write-Host "packaging dalbit.vsix..."

# Build .vsix (a ZIP with specific structure)
$TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "dalbit-vsix-$(Get-Random)"
New-Item -ItemType Directory -Path $TmpDir | Out-Null
New-Item -ItemType Directory -Path (Join-Path $TmpDir "extension\themes") -Force | Out-Null

Copy-Item (Join-Path $ScriptDir "package.json") (Join-Path $TmpDir "extension\package.json")
Copy-Item (Join-Path $ScriptDir "themes\dalbit-color-theme.json") (Join-Path $TmpDir "extension\themes\dalbit-color-theme.json")

# [Content_Types].xml — use WriteAllText to avoid encoding/bracket issues
$ContentTypesXml = @"
<?xml version="1.0" encoding="utf-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension=".json" ContentType="application/json"/>
  <Default Extension=".vsixmanifest" ContentType="text/xml"/>
</Types>
"@
[System.IO.File]::WriteAllText(
    (Join-Path $TmpDir "[Content_Types].xml"),
    $ContentTypesXml,
    [System.Text.Encoding]::UTF8
)

# extension.vsixmanifest
$Manifest = @"
<?xml version="1.0" encoding="utf-8"?>
<PackageManifest Version="2.0.0" xmlns="http://schemas.microsoft.com/developer/vsx-schema/2011">
  <Metadata>
    <Identity Language="en-US" Id="dalbit" Version="0.1.0" Publisher="jongukc"/>
    <DisplayName>dalbit</DisplayName>
    <Description xml:space="preserve">Warm accents on neutral dark, inspired by Gruber-Darker</Description>
    <Properties>
      <Property Id="Microsoft.VisualStudio.Code.Engine" Value="^1.55.0"/>
    </Properties>
    <Categories>Themes</Categories>
  </Metadata>
  <Installation>
    <InstallationTarget Id="Microsoft.VisualStudio.Code"/>
  </Installation>
  <Dependencies/>
  <Assets>
    <Asset Type="Microsoft.VisualStudio.Code.Manifest" Path="extension/package.json" Addressable="true"/>
  </Assets>
</PackageManifest>
"@
[System.IO.File]::WriteAllText(
    (Join-Path $TmpDir "extension.vsixmanifest"),
    $Manifest,
    [System.Text.Encoding]::UTF8
)

# Create ZIP -> rename to .vsix
$ZipPath = $Vsix -replace '\.vsix$', '.zip'
if (Test-Path $Vsix) { Remove-Item $Vsix }
if (Test-Path $ZipPath) { Remove-Item $ZipPath }
Compress-Archive -Path (Join-Path $TmpDir "*") -DestinationPath $ZipPath -Force
Rename-Item $ZipPath $Vsix
Remove-Item -Recurse -Force $TmpDir

Write-Host "built: $Vsix"

# Install via code CLI
$CodeCmd = Get-Command code -ErrorAction SilentlyContinue
if ($CodeCmd) {
    & code --install-extension $Vsix --force
    Write-Host ""
    Write-Host "installed! restart VS Code, then:"
    Write-Host "  Ctrl+Shift+P -> Preferences: Color Theme -> dalbit"
} else {
    Write-Host ""
    Write-Host "warning: 'code' command not found in PATH"
    Write-Host "install manually: code --install-extension $Vsix"
}
