# Repository Guidelines

## 重要なルール

- **git commitは絶対に勝手に行わないこと**: コミットはユーザーの明示的な許可を得てから実行する。スキルやサブエージェントを含む全ての操作において、自動的にコミットしてはならない。

## Project Structure

```
./
├── .config/              # XDG準拠の設定
│   ├── ghostty/          # Ghosttyターミナル
│   ├── nvim/             # Neovim
│   ├── yazi/             # ファイルマネージャー
│   └── zellij/           # ターミナルマルチプレクサ
├── .local/bin/           # カスタムスクリプト (git-dashboard等)
├── shell/                # シェル設定
│   ├── .zshrc, .zshenv   # zsh
│   ├── .zpreztorc        # prezto
│   ├── .p10k.zsh         # powerlevel10k
│   ├── .bashrc           # bash
│   └── .tmux.conf        # tmux
├── scripts/              # メンテナンススクリプト
│   ├── cleanup.sh
│   └── generate_gitconfig.sh
├── install.sh            # エントリーポイント
└── aqua.yaml             # CLIツール定義
```

## Commands

- `./install.sh` - フルインストール（Homebrew、prezto、dotfilesリンク、Neovimプラグイン）
- `./scripts/generate_gitconfig.sh` - .gitconfigを生成
- `./scripts/cleanup.sh` - $HOMEからリンクを削除（バックアップあり）

## Coding Style

- Shell: Bash (`#!/bin/bash`), `set -e`, 4スペースインデント
- Lua (Neovim): 2スペースインデント
- Commit: Conventional Commit (`fix:`, `feat:`, `refactor:`)

## Testing

自動テストなし。`./install.sh`を安全な環境で実行し、シンボリックリンクを確認。
