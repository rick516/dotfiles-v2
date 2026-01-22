# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal dotfiles for macOS development environment setup. Includes zsh (with prezto + powerlevel10k), Neovim (Lua-based config), and tmux configurations.

## Commands

```bash
# Full installation (links dotfiles, installs packages, sets up Neovim plugins)
./install.sh

# Generate .gitconfig from template (prompts for name/email)
./generate_gitconfig.sh

# Remove linked dotfiles from $HOME (backs up to backups/)
./cleanup.sh
```

## Structure

- Root level: dotfiles (`.zshrc`, `.tmux.conf`, `.p10k.zsh`, `.zpreztorc`, etc.)
- `.config/nvim/init.lua`: Neovim configuration
- `install.sh`: Main setup script - installs Homebrew packages, prezto, powerlevel10k, links dotfiles
- `cleanup.sh`: Removes symlinks from $HOME, creates timestamped backups
- `generate_gitconfig.sh`: Creates `.gitconfig` from `.gitconfig_template`
- `backups/`: Timestamped backups created by cleanup.sh

## Code Style

- Shell scripts: Bash with `set -e`, 4-space indentation
- Lua (Neovim): 2-space indentation
- Commit messages: Conventional Commit style (`fix:`, `feat:`)

## Testing

No automated tests. Validate by running `./install.sh` in safe environment and verifying symlinks in `$HOME`. For Neovim, open `nvim` and confirm plugins load.
