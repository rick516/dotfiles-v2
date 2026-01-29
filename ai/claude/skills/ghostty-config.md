# Ghostty Configuration Customization Skill

Ghosttyターミナルエミュレーターの設定カスタマイズガイド。dotfiles-v2で管理されたGhostty設定を安全かつ効率的にカスタマイズする方法を提供します。

## 使用タイミング

- Ghosttyの外観（テーマ、フォント、透明度）を変更したい
- キーバインドを追加・変更したい
- zellijレイアウトや起動コマンドを変更したい
- クイックターミナルの設定を調整したい

---

## ファイル構成

```
dotfiles-v2/
├── .config/
│   └── ghostty/
│       └── config          # ソース設定（__HOME__プレースホルダー使用）
└── install.sh              # 設定展開スクリプト
```

### 設定ファイルの配置先

| 場所 | 用途 |
|------|------|
| `dotfiles-v2/.config/ghostty/config` | ソース（編集対象） |
| `~/.config/ghostty/config` | コピー先（展開済み） |
| `~/Library/Application Support/com.mitchellh.ghostty/config` | macOS実行時読み込み先 |

---

## __HOME__プレースホルダーパターン

### 概要
公開リポジトリでユーザー名などの個人情報を含めないため、パスには`__HOME__`プレースホルダーを使用します。

```bash
# ソースファイル内
command = __HOME__/.local/bin/zellij-launch --layout vscode

# install.sh実行後（展開済み）
command = /Users/username/.local/bin/zellij-launch --layout vscode
```

### 展開の仕組み

`install.sh`がコピー時に自動展開します：

```bash
cp "$src" "$dest"
sed -i '' "s|__HOME__|$HOME|g" "$dest"
```

### 編集時の注意

1. **必ずソースファイルを編集**
   ```bash
   # 正しい
   vim ~/dotfiles-v2/.config/ghostty/config

   # 間違い（次回install.shで上書きされる）
   vim ~/.config/ghostty/config
   ```

2. **編集後は再展開が必要**
   ```bash
   ./install.sh
   # または手動で
   cp ~/.config/ghostty/config ~/Library/Application\ Support/com.mitchellh.ghostty/config
   sed -i '' "s|__HOME__|$HOME|g" ~/Library/Application\ Support/com.mitchellh.ghostty/config
   ```

---

## 設定オプションリファレンス

### テーマ・外観

```ini
# テーマ（組み込みテーマ名）
theme = TokyoNight

# フォント
font-family = "PlemolJP35 Console NF"
font-thicken
adjust-cell-height = 2

# 背景（透過 + ブラー）
background = 000
background-opacity = 0.70
background-blur = true
```

### カーソル

```ini
cursor-style = block        # block, bar, underline
cursor-style-blink = false
```

### ウィンドウ

```ini
title = " "
window-padding-x = 5
window-padding-y = 5
window-padding-balance = true
window-inherit-working-directory = true
window-new-tab-position = current

# 全画面
fullscreen
macos-non-native-fullscreen = true
macos-titlebar-style = transparent
```

### macOSアイコン

```ini
macos-icon = custom-style
macos-icon-ghost-color = fa5    # 16進カラー
macos-icon-screen-color = 000
```

### クイックターミナル

```ini
quick-terminal-screen = mouse
quick-terminal-position = right   # left, right, top, bottom
quick-terminal-animation-duration = 0.3
keybind = cmd+shift+t=toggle_quick_terminal
```

### クリップボード

```ini
clipboard-read = allow
clipboard-write = allow
clipboard-trim-trailing-spaces = true
copy-on-select = clipboard
selection-invert-fg-bg = true
```

### 起動コマンド

```ini
# zellij-launchでディレクトリ選択付き起動
command = __HOME__/.local/bin/zellij-launch --layout vscode

# コマンド終了後も表示を維持
wait-after-command = true
```

### その他

```ini
mouse-hide-while-typing
shell-integration = detect
macos-option-as-alt = true
scrollback-limit = 10000
confirm-close-surface = false
```

---

## カスタマイズ例

### 透明度を調整

```ini
# 50%透過（より透明）
background-opacity = 0.50

# 90%透過（ほぼ不透明）
background-opacity = 0.90
```

### キーバインド追加

```ini
# 新しいタブ
keybind = cmd+t=new_tab

# ペイン分割
keybind = cmd+d=new_split:right
keybind = cmd+shift+d=new_split:down

# フォントサイズ
keybind = cmd+plus=increase_font_size:1
keybind = cmd+minus=decrease_font_size:1
```

### 別のシェルを使用

```ini
# fish
command = /opt/homebrew/bin/fish

# tmux
command = /opt/homebrew/bin/tmux
```

---

## トラブルシューティング

### 設定が反映されない

1. 正しい場所のファイルを編集しているか確認
   ```bash
   # ソースを編集
   vim ~/dotfiles-v2/.config/ghostty/config
   ```

2. install.shを再実行
   ```bash
   cd ~/dotfiles-v2 && ./install.sh
   ```

3. Ghosttyを再起動

### __HOME__が展開されない

Library配下のファイルがシンボリックリンクになっている可能性：

```bash
# 確認
ls -la ~/Library/Application\ Support/com.mitchellh.ghostty/config

# シンボリックリンクの場合は削除して再展開
rm ~/Library/Application\ Support/com.mitchellh.ghostty/config
./install.sh
```

### フォントが表示されない

```bash
# インストール確認
brew list --cask font-plemol-jp-nf

# 再インストール
brew install --cask font-plemol-jp-nf
```

---

## 関連ファイル

- `dotfiles-v2/.config/zellij/layouts/vscode.kdl` - zellijレイアウト
- `dotfiles-v2/.local/bin/zellij-launch` - 起動ラッパースクリプト
- `dotfiles-v2/.local/bin/git-dashboard` - Git状態表示スクリプト
- `dotfiles-v2/aqua.yaml` - CLIツールバージョン管理
