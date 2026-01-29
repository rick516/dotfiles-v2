# Zellij Layout Customization Skill

zellijターミナルマルチプレクサーのレイアウトカスタマイズガイド。KDL形式でのレイアウト定義とカスタマイズ方法を提供します。

## 使用タイミング

- zellijのペインレイアウトを変更したい
- 起動時に自動実行するコマンドを設定したい
- 新しいレイアウトテンプレートを作成したい

---

## ファイル構成

```
dotfiles-v2/
├── .config/
│   └── zellij/
│       ├── config.kdl      # メイン設定
│       └── layouts/
│           └── vscode.kdl  # VSCode風レイアウト
└── .local/
    └── bin/
        ├── zellij-launch   # 起動ラッパー
        └── git-dashboard   # Git状態表示
```

---

## __HOME__プレースホルダー

ghostty-config.mdと同様、パスには`__HOME__`を使用：

```kdl
pane {
    command "__HOME__/.local/share/aquaproj-aqua/bin/yazi"
}
```

`install.sh`実行時に実際のパスに展開されます。

---

## KDLレイアウト構文

### 基本構造

```kdl
layout {
    pane split_direction="vertical" {
        pane size="30%"
        pane size="70%"
    }
}
```

### 分割方向

```kdl
// 水平分割（上下）
pane split_direction="horizontal" {
    pane  // 上
    pane  // 下
}

// 垂直分割（左右）
pane split_direction="vertical" {
    pane  // 左
    pane  // 右
}
```

### サイズ指定

```kdl
pane size="25%"      // パーセント
pane size=10         // 固定行数
```

### コマンド実行

```kdl
pane {
    command "__HOME__/.local/share/aquaproj-aqua/bin/yazi"
}

// 引数付き
pane {
    command "nvim"
    args "-c" "NvimTreeToggle"
}
```

### フォーカス指定

```kdl
pane focus=true
```

---

## 現在のVSCodeレイアウト

```kdl
// VSCode風レイアウト
layout {
    pane split_direction="vertical" {
        // 左サイドバー（25%）
        pane size="25%" split_direction="horizontal" {
            // ファイルエクスプローラー（60%）
            pane size="60%" {
                command "__HOME__/.local/share/aquaproj-aqua/bin/yazi"
            }
            // Git状態表示（40%）
            pane size="40%" {
                command "__HOME__/.local/bin/git-dashboard"
            }
        }
        // メインエディタ領域（75%）
        pane size="75%" split_direction="horizontal" {
            // 上段
            pane size="50%" split_direction="vertical" {
                pane
                pane
            }
            // 下段
            pane size="50%" split_direction="vertical" {
                pane
                pane
            }
        }
    }
}
```

### 構成

```
┌────────────┬───────────────────────────────┐
│            │               │               │
│   yazi     │    pane 1     │    pane 2     │
│ (60%)      │               │               │
├────────────┼───────────────┼───────────────┤
│            │               │               │
│ git-dash   │    pane 3     │    pane 4     │
│ (40%)      │               │               │
└────────────┴───────────────┴───────────────┘
    25%                  75%
```

---

## カスタマイズ例

### シンプル3ペイン

```kdl
layout {
    pane split_direction="vertical" {
        pane size="20%" {
            command "__HOME__/.local/share/aquaproj-aqua/bin/yazi"
        }
        pane size="80%" split_direction="horizontal" {
            pane size="70%"   // メイン
            pane size="30%"   // ターミナル
        }
    }
}
```

### 開発+テスト

```kdl
layout {
    pane split_direction="horizontal" {
        pane size="70%" split_direction="vertical" {
            pane size="30%" {
                command "__HOME__/.local/share/aquaproj-aqua/bin/yazi"
            }
            pane size="70%"  // エディタ
        }
        pane size="30%" {
            // テスト実行用
        }
    }
}
```

### フルスクリーンエディタ

```kdl
layout {
    pane {
        command "nvim"
    }
}
```

---

## 新しいレイアウトの追加

1. レイアウトファイルを作成
   ```bash
   vim ~/dotfiles-v2/.config/zellij/layouts/custom.kdl
   ```

2. install.shを実行
   ```bash
   cd ~/dotfiles-v2 && ./install.sh
   ```

3. zellij-launchで使用
   ```bash
   zellij-launch --layout custom
   ```

4. Ghosttyのデフォルトにする場合
   ```ini
   # dotfiles-v2/.config/ghostty/config
   command = __HOME__/.local/bin/zellij-launch --layout custom
   ```

---

## zellij-launchスクリプト

起動時にfzfでディレクトリを選択できるラッパースクリプト：

```bash
#!/bin/bash
export AQUA_ROOT_DIR="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}"
export PATH="/opt/homebrew/bin:$AQUA_ROOT_DIR/bin:$PATH"

# ディレクトリ候補
PROJECT_DIRS=(
    "$HOME"
    "$HOME/Documents/Dev"
    "$HOME/dotfiles-v2"
)

# fzfで選択
selected=$(get_dirs | fzf --height=40% --reverse --prompt="Directory: ")
cd "$selected" || cd "$HOME"

# zellij起動
exec zellij "$@"
```

---

## キーバインド

zellijのデフォルトキーバインド（主要なもの）：

| キー | 動作 |
|------|------|
| `Ctrl+p` | ペインモード |
| `Ctrl+t` | タブモード |
| `Ctrl+n` | リサイズモード |
| `Ctrl+o` | セッションモード |
| `Ctrl+s` | 検索モード |
| `Ctrl+g` | ロック（通常モードに戻る） |

### ペインモード（Ctrl+p後）

| キー | 動作 |
|------|------|
| `h/j/k/l` | ペイン移動 |
| `n` | 新規ペイン（下） |
| `d` | 新規ペイン（右） |
| `x` | ペインを閉じる |
| `f` | フルスクリーン切り替え |
| `w` | フローティング切り替え |

---

## トラブルシューティング

### コマンドが見つからない

aqua PATHが通っていない可能性：

```kdl
// フルパスを使用
pane {
    command "__HOME__/.local/share/aquaproj-aqua/bin/yazi"
}
```

### レイアウトが反映されない

1. install.shを再実行
2. __HOME__が展開されているか確認
   ```bash
   cat ~/.config/zellij/layouts/vscode.kdl | grep HOME
   ```

### git-dashboardが動かない

実行権限と PATH を確認：

```bash
chmod +x ~/dotfiles-v2/.local/bin/git-dashboard
./install.sh
```

---

## 関連ファイル

- `dotfiles-v2/.config/ghostty/config` - Ghostty設定
- `dotfiles-v2/.config/zellij/config.kdl` - zellijメイン設定
- `dotfiles-v2/aqua.yaml` - zellij バージョン管理
