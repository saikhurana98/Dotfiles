#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_INIT="$DOTFILES_DIR/shared/nvim/init.lua"
TARGET_DIR="${HOME}/.config/nvim"
TARGET_INIT="${TARGET_DIR}/init.lua"
BACKUP_SUFFIX="$(date +%Y%m%d%H%M%S)"

if ! command -v nvim >/dev/null 2>&1; then
  echo "Neovim is not installed. Install it first, then rerun this script."
  exit 1
fi

mkdir -p "$TARGET_DIR"

if [ ! -f "$SOURCE_INIT" ]; then
  echo "Missing source config: $SOURCE_INIT"
  exit 1
fi

if [ -e "$TARGET_INIT" ] && [ ! -L "$TARGET_INIT" ]; then
  mv "$TARGET_INIT" "${TARGET_INIT}.bak.${BACKUP_SUFFIX}"
  echo "Backed up existing init.lua to ${TARGET_INIT}.bak.${BACKUP_SUFFIX}"
fi

ln -sfn "$SOURCE_INIT" "$TARGET_INIT"
echo "Linked $SOURCE_INIT -> $TARGET_INIT"

mkdir -p "${HOME}/.local/share/nvim"

cat <<'EOF'

Neovim config installed.

Next steps:
1. Open Neovim with: nvim
2. Wait for plugins to install on first launch.
3. Authenticate Copilot with: :Copilot auth

Useful keys:
- <leader>e toggles the file sidebar
- <leader>o focuses the file sidebar
- <leader>cc opens Copilot Chat
- Visual mode + <leader>ce explains selected code
EOF
