# Dotfiles

Personal configuration files for macOS, Linux, and Windows.

## Structure

- `macos/`: Configuration files specific to macOS (e.g., `Brewfile`).
- `linux/`: Configuration files specific to Linux distributions.
- `windows/`: Configuration files specific to Windows.
- `shared/`: Configuration files and scripts shared across multiple operating systems (e.g., `zinit` setup, `ssh_config`).

## Usage

### Zinit Setup
To set up Zinit and zsh, run:
```bash
bash shared/setup-zinit.sh
```

### macOS Homebrew
To install Homebrew packages:
```bash
brew bundle --file=macos/Brewfile
```
