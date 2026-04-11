#!/bin/bash

set -e

echo "Starting Zinit setup script..."

# Detect OS and package manager
OS="$(uname -s)"
case "${OS}" in
    Linux*)
        if [ -f /etc/debian_version ]; then
            PKG_MGR="apt-get"
            UPDATE_CMD="sudo apt-get update"
            INSTALL_CMD="sudo apt-get install -y"
        elif [ -f /etc/arch-release ]; then
            PKG_MGR="pacman"
            UPDATE_CMD="sudo pacman -Sy"
            INSTALL_CMD="sudo pacman -S --noconfirm"
        else
            echo "Unsupported Linux distribution. Please install zsh manually."
            exit 1
        fi
        ;;
    Darwin*)
        PKG_MGR="brew"
        INSTALL_CMD="brew install"
        ;;
    *)
        echo "Unsupported OS: ${OS}. Please install zsh manually."
        exit 1
        ;;
esac

# Install dependencies: git, curl, zsh
DEPS="git curl zsh"
for dep in $DEPS; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        echo "Installing $dep..."
        if [ -n "$UPDATE_CMD" ]; then
            $UPDATE_CMD
            UPDATE_CMD="" # Only run update once
        fi
        $INSTALL_CMD "$dep"
    else
        echo "$dep is already installed."
    fi
done

# Set Zinit home directory
ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"

# Install Zinit if not already installed
if [ ! -d "${ZINIT_HOME}" ]; then
    echo "Installing Zinit..."
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}"
else
    echo "Zinit is already installed at ${ZINIT_HOME}."
fi

# Prepare Zinit configuration block
ZSHRC="${HOME}/.zshrc"
ZINIT_BLOCK_FILE=$(mktemp)
cat <<'EOF' > "$ZINIT_BLOCK_FILE"

### Zinit Setup ###
ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"
if [[ ! -f "${ZINIT_HOME}/zinit.zsh" ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})...%f"
    command mkdir -p "$(dirname "$ZINIT_HOME")" && command chmod g-rwX "$(dirname "$ZINIT_HOME")"
    command git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" && \
        print -P "%F{33} %F{34}Installation successful.%f%u" || \
        print -P "%F{160} The clone has failed.%f%u"
fi

source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Default example configuration
# Load the pure theme, with zsh-async library that's bundled with it.
zi ice pick"async.zsh" src"pure.zsh"
zi light sindresorhus/pure

# A glance at the new for-syntax – load all of the above
# plugins with a single command. For more information see:
# https://zdharma-continuum.github.io/zinit/wiki/For-Syntax/
zinit for \
    light-mode \
  zsh-users/zsh-autosuggestions \
    light-mode \
  zdharma-continuum/fast-syntax-highlighting \
  zdharma-continuum/history-search-multi-word \
    light-mode \
    pick"async.zsh" \
    src"pure.zsh" \
  sindresorhus/pure

# Binary release in archive, from GitHub-releases page.
# After automatic unpacking it provides program "fzf".
zi ice from"gh-r" as"program"
zi light junegunn/fzf

# One other binary release, it needs renaming from `docker-compose-Linux-x86_64`.
# This is done by ice-mod `mv'{from} -> {to}'. There are multiple packages per
# single version, for OS X, Linux and Windows – so ice-mod `bpick' is used to
# select Linux package – in this case this is actually not needed, Zinit will
# grep operating system name and architecture automatically when there's no `bpick'.
zi ice from"gh-r" as"program" mv"docker* -> docker-compose" bpick"*linux*"
zi load docker/compose

# Vim repository on GitHub – a typical source code that needs compilation – Zinit
# can manage it for you if you like, run `./configure` and other `make`, etc.
# Ice-mod `pick` selects a binary program to add to $PATH. You could also install the
# package under the path $ZPFX, see: https://zdharma-continuum.github.io/zinit/wiki/Compiling-programs
zi ice \
  as"program" \
  atclone"rm -f src/auto/config.cache; ./configure" \
  atpull"%atclone" \
  make \
  pick"src/vim"
zi light vim/vim

# Scripts built at install (there's single default make target, "install",
# and it constructs scripts by `cat'ing a few files). The make'' ice could also be:
# `make"install PREFIX=$ZPFX"`, if "install" wouldn't be the only default target.
zi ice as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
zi light tj/git-extras

# Handle completions without loading any plugin; see "completions" command.
# This one is to be ran just once, in interactive session.
zi creinstall %HOME/my_completions
### End Zinit Setup ###
EOF

# Add Zinit block to .zshrc
if [ ! -f "$ZSHRC" ]; then
    echo "Creating $ZSHRC..."
    cat "$ZINIT_BLOCK_FILE" > "$ZSHRC"
elif ! grep -q "### Zinit Setup ###" "$ZSHRC"; then
    echo "Adding Zinit configuration to $ZSHRC..."
    cat "$ZINIT_BLOCK_FILE" >> "$ZSHRC"
else
    echo "Updating Zinit configuration in $ZSHRC..."
    # Create backup
    cp "$ZSHRC" "${ZSHRC}.bak"
    # Use python to replace the block
    python3 -c "import os, re; zshrc=os.path.expanduser('~/.zshrc'); block=open('$ZINIT_BLOCK_FILE').read(); content=open(zshrc).read(); content=re.sub(r'### Zinit Setup ###.*?### End Zinit Setup ###', block, content, flags=re.DOTALL); open(zshrc, 'w').write(content)"
fi

rm "$ZINIT_BLOCK_FILE"

# Change default shell to zsh if necessary
CURRENT_SHELL=$(basename "$SHELL")
ZSH_PATH=$(command -v zsh)

if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "Changing default shell to zsh..."
    if [ "$OS" = "Darwin" ]; then
        chsh -s "$ZSH_PATH"
    else
        sudo chsh -s "$ZSH_PATH" "$(whoami)"
    fi
fi

echo "Zinit setup complete! Please restart your terminal or run 'zsh'."
