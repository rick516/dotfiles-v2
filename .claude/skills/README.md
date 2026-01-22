# dotfiles-v2 Skills

dotfiles-v2のカスタマイズに特化したClaude Codeスキル集。

## 利用可能なスキル

| スキル | 用途 |
|--------|------|
| [ghostty-config](./ghostty-config.md) | Ghosttyターミナル設定カスタマイズ |
| [zellij-layout](./zellij-layout.md) | zellijレイアウトカスタマイズ |

## 使用方法

Claude Codeで以下のようにリクエスト：

```
「Ghosttyの透明度を変更したい」
「zellijのレイアウトを3ペインにしたい」
「新しいキーバインドを追加したい」
```

## 共通パターン

### __HOME__プレースホルダー

公開リポジトリで個人情報を含めないため、ホームディレクトリパスには`__HOME__`を使用：

```
__HOME__/.local/bin/script → /Users/username/.local/bin/script
```

`install.sh`実行時に自動展開されます。

### 編集→展開フロー

1. ソースファイルを編集（`dotfiles-v2/`配下）
2. `./install.sh`で展開
3. アプリを再起動

### 対象ディレクトリ

| 用途 | ソース | 展開先 |
|------|--------|--------|
| Ghostty設定 | `.config/ghostty/` | `~/.config/ghostty/` + `~/Library/Application Support/com.mitchellh.ghostty/` |
| zellij設定 | `.config/zellij/` | `~/.config/zellij/` |
| スクリプト | `.local/bin/` | `~/.local/bin/` |

## 追加リソース

- [Ghostty公式ドキュメント](https://ghostty.org/docs)
- [zellij公式ドキュメント](https://zellij.dev/documentation/)
- [aqua](https://aquaproj.github.io/) - CLIバージョン管理
