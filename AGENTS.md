# Repository Guidelines

## 重要なルール

- **git commitは絶対に勝手に行わないこと**: コミットはユーザーの明示的な許可を得てから実行する。スキルやサブエージェントを含む全ての操作において、自動的にコミットしてはならない。

- **個人情報を含めないこと**: このリポジトリはPublicのため、以下の情報を絶対に含めない：
  - ユーザー名（`/Users/username/` 等のハードコードパス）
  - メールアドレス
  - APIキー・トークン
  - その他個人を特定できる情報

- **__HOME__プレースホルダーを使用すること**: パスにホームディレクトリを含める場合は、ハードコードせず `__HOME__` プレースホルダーを使用する。
  ```
  # 正しい
  command = __HOME__/.local/bin/script

  # 間違い（個人情報漏洩）
  command = /Users/username/.local/bin/script
  ```
  `install.sh` がコピー時に `$HOME` に展開する。

- **機密ファイルは.gitignoreに追加すること**: `.envrc`、認証情報を含むファイルは必ず `.gitignore` に追加する。

- **個人情報をコミットしたら履歴ごと消すこと**: PRでは過去の履歴は消えない。`git filter-repo`でforce-pushが必要。
  ```bash
  # 履歴から個人情報を削除
  git filter-repo --replace-text <(echo "個人名==>username") --force
  git remote add origin <url>
  git push --force origin main  # ブランチ保護の一時解除が必要
  ```

## Project Structure

```
./
├── .claude/              # Claude Code設定
│   └── skills/           # カスタマイズスキル
│       ├── ghostty-config.md
│       └── zellij-layout.md
├── .config/              # XDG準拠の設定（__HOME__展開が必要）
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

- `./install.sh` - フルインストール（Homebrew、prezto、dotfilesリンク、__HOME__展開、Neovimプラグイン）
- `./scripts/generate_gitconfig.sh` - .gitconfigを生成
- `./scripts/cleanup.sh` - $HOMEからリンクを削除（バックアップあり）

## Coding Style

- Shell: Bash (`#!/bin/bash`), `set -e`, 4スペースインデント
- Lua (Neovim): 2スペースインデント
- Commit: Conventional Commit (`fix:`, `feat:`, `refactor:`)

## Testing

自動テストなし。`./install.sh`を安全な環境で実行し、シンボリックリンクを確認。
