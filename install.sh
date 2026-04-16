#!/usr/bin/env bash
set -euo pipefail

EXT_NAME="jongukc.dalbit-0.1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect extensions directory
if [[ -d "${HOME}/.vscode/extensions" ]]; then
    EXT_DIR="${HOME}/.vscode/extensions"
elif [[ -d "${HOME}/.vscode-server/extensions" ]]; then
    EXT_DIR="${HOME}/.vscode-server/extensions"
else
    echo "error: could not find VS Code extensions directory"
    echo "  tried: ~/.vscode/extensions, ~/.vscode-server/extensions"
    exit 1
fi

TARGET="${EXT_DIR}/${EXT_NAME}"

if [[ -e "$TARGET" ]]; then
    echo "removing existing ${TARGET}"
    rm -rf "$TARGET"
fi

ln -s "$SCRIPT_DIR" "$TARGET"
echo "installed: ${TARGET} → ${SCRIPT_DIR}"
echo ""
echo "restart VS Code, then:"
echo "  Ctrl+Shift+P → Preferences: Color Theme → dalbit"
