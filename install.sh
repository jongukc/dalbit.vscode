#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VSIX="${SCRIPT_DIR}/dalbit.vsix"

echo "packaging dalbit.vsix..."

# Build .vsix (a ZIP with specific structure)
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "${TMPDIR}/extension/themes"
cp "${SCRIPT_DIR}/package.json" "${TMPDIR}/extension/"
cp "${SCRIPT_DIR}/themes/dalbit-color-theme.json" "${TMPDIR}/extension/themes/"

# [Content_Types].xml — required by VSIX format
cat >"${TMPDIR}/[Content_Types].xml" <<'XMLEOF'
<?xml version="1.0" encoding="utf-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension=".json" ContentType="application/json"/>
  <Default Extension=".vsixmanifest" ContentType="text/xml"/>
</Types>
XMLEOF

# extension.vsixmanifest — required by VSIX format
cat >"${TMPDIR}/extension.vsixmanifest" <<'XMLEOF'
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
XMLEOF

(cd "$TMPDIR" && zip -rq "$VSIX" .)
echo "built: ${VSIX}"

# Install via code CLI
if command -v code &>/dev/null; then
    code --install-extension "$VSIX" --force
    echo ""
    echo "installed! restart VS Code, then:"
    echo "  Ctrl+Shift+P → Preferences: Color Theme → Dalbit"
else
    echo ""
    echo "warning: 'code' command not found"
    echo "install manually: code --install-extension ${VSIX}"
fi
