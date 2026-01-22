# Repository Guidelines

## 重要なルール

- **git commitは絶対に勝手に行わないこと**: コミットはユーザーの明示的な許可を得てから実行する。スキルやサブエージェントを含む全ての操作において、自動的にコミットしてはならない。

## Project Structure & Module Organization

- Shell configs are in `shell/` (e.g., `.zshrc`, `.tmux.conf`, `.p10k.zsh`).
- XDG configs are in `.config/` (nvim, ghostty, yazi, zellij).
- Custom scripts are in `.local/bin/` (e.g., `git-dashboard`).
- Maintenance scripts are in `scripts/` (`cleanup.sh`, `generate_gitconfig.sh`).
- Entry point `install.sh` remains at root.
- Backups created by scripts are stored under `backups/` with timestamped names.

## Build, Test, and Development Commands

- `./install.sh` sets up Homebrew packages, installs prezto/powerlevel10k, links dotfiles into `$HOME`, and installs Neovim plugins.
- `./scripts/generate_gitconfig.sh` generates `$HOME/.gitconfig` from `.gitconfig_template` if missing.
- `./scripts/cleanup.sh` removes linked dotfiles from `$HOME` and backs them up. Use with caution; it deletes local files.

## Coding Style & Naming Conventions

- Scripts are Bash (`#!/bin/bash`) and rely on `set -e` for early failure.
- Indentation is 2 spaces in Lua (`.config/nvim/init.lua`) and 4 spaces in shell scripts; keep existing style in-file.
- Dotfiles should keep their leading dot name (e.g., `.zpreztorc`, `.zshenv`).
- Use clear, descriptive function names in shell scripts (`install_homebrew`, `process_directory`).

## Testing Guidelines

- There is no automated test suite in this repo.
- Validate changes manually by running `./install.sh` in a safe environment and verifying symlink targets in `$HOME`.
- For Neovim changes, open `nvim` and confirm plugins load; `:PackerSync` is used by `install.sh`.

## Commit & Pull Request Guidelines

- Recent commits use Conventional Commit-style prefixes (e.g., `fix:`, `feat:`). Follow that pattern.
- Keep commits scoped to a single concern (e.g., “fix: update zpreztorc theme”).
- PRs should include: a short summary, the commands run (if any), and any manual verification notes.

## Security & Configuration Tips

- `cleanup.sh` and `install.sh` modify files in `$HOME`; ensure you have backups.
- `.gitconfig` is generated from `.gitconfig_template`; avoid committing personal credentials.
