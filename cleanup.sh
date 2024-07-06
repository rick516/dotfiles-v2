#!/bin/bash

# WARN: ローカル環境のファイルを削除するコマンドです。注意！！！
# WARN: ローカル環境のファイルを削除するコマンドです。注意！！！
# WARN: ローカル環境のファイルを削除するコマンドです。注意！！！

# dotfilesディレクトリのパス（必要に応じて変更してください）
DOTFILES_DIR="$HOME/dotfiles-v2"

# バックアップディレクトリ
BACKUP_DIR="$HOME/dotfiles-v2/backups/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# ログ関数
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# エラーハンドリング
error() {
    log "エラー: $1" >&2
    exit 1
}

# バックアップディレクトリの作成
mkdir -p "$BACKUP_DIR" || error "バックアップディレクトリの作成に失敗しました"

# dotfilesディレクトリ内のファイルを処理
process_dotfiles() {
    local dir="$1"
    local rel_path="${dir#$DOTFILES_DIR/}"

    # バックアップディレクトリをスキップ
    if [[ "$dir" == *"/backups/"* ]]; then
        log "バックアップディレクトリをスキップ: $dir"
        return
    fi

    for item in "$dir"/* "$dir"/.[!.]*; do
        [ -e "$item" ] || continue
        
        local item_rel_path="${item#$DOTFILES_DIR/}"
        local home_path="$HOME/${item_rel_path#.}"

        if [ -d "$item" ]; then
            process_dotfiles "$item"
        elif [ -f "$item" ]; then
            if [ -e "$home_path" ]; then
                log "バックアップ中: $home_path"
                mv "$home_path" "$BACKUP_DIR/" || error "$home_path のバックアップに失敗しました"
            fi
            log "削除中: $home_path"
            rm -f "$home_path" || error "$home_path の削除に失敗しました"
        fi
    done
}

# preztoの設定をクリーンアップする関数
cleanup_prezto() {
    local prezto_dir="${ZDOTDIR:-$HOME}/.zprezto"
    if [ -d "$prezto_dir" ]; then
        log "Cleaning up prezto configuration..."
        rm -f "${ZDOTDIR:-$HOME}"/.{zlogin,zlogout,zpreztorc,zprofile,zshenv,zshrc}
        mv "$prezto_dir" "$BACKUP_DIR/" || error "Failed to move prezto directory to backup"
    fi
}

# メイン処理
main() {
    log "dotfilesの初期化を開始します..."

    # dotfilesディレクトリの存在確認
    if [ ! -d "$DOTFILES_DIR" ]; then
        error "dotfilesディレクトリが見つかりません: $DOTFILES_DIR"
    fi

    # dotfilesの処理
    process_dotfiles "$DOTFILES_DIR"

    # 特定のファイルやディレクトリの削除
    local items_to_remove=(
        "$HOME/.zshrc"
        "$HOME/.zpreztorc"
        "$HOME/.zprofile"
        "$HOME/.zshenv"
        "$HOME/.p10k.zsh"
        "$HOME/.gitconfig"
        "$HOME/.config/nvim"
    )

    for item in "${items_to_remove[@]}"; do
        if [ -e "$item" ]; then
            log "バックアップ中: $item"
            mkdir -p "$(dirname "$BACKUP_DIR${item#$HOME}")"
            cp -a "$item" "$BACKUP_DIR${item#$HOME}" || error "$item のバックアップに失敗しました"
            log "削除中: $item"
            rm -rf "$item" || error "$item の削除に失敗しました"
        fi
    done

    # preztoの設定をクリーンアップ
    cleanup_prezto

    log "dotfilesの初期化が完了しました。バックアップは $BACKUP_DIR に保存されています。"
}

# スクリプトの実行
main
