#!/bin/bash

set -e

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# ログ関数
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# エラーハンドリング
error() {
    log "ERROR: $1" >&2
    exit 1
}

# Homebrewのインストール
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || error "Failed to install Homebrew"
    else
        log "Homebrew is already installed."
    fi
}

# ホームディレクトリを取得
HOME_DIR=$(eval echo ~$USER)

# 必要なパッケージのインストール
install_packages() {
    log "Installing necessary packages..."
    brew install fzf ripgrep neovim tmux || error "Failed to install packages"
    
    # fzfのインストール時に.zshrcを変更しないようにする
    $(brew --prefix)/opt/fzf/install --no-update-rc --key-bindings --completion || error "Failed to install fzf"

}

# Neovimの設定
setup_neovim() {
    local nvim_config_dir="$HOME/.config/nvim"
    local nvim_config="$nvim_config_dir/init.lua"
    
    if [ ! -d "$nvim_config_dir" ]; then
        mkdir -p "$nvim_config_dir"
    fi

    if [ ! -f "$nvim_config" ]; then
        log "Creating Neovim configuration file..."
        cp "$DOTFILES_DIR/init.lua" "$nvim_config" || error "Failed to create Neovim config"
    fi

    if ! grep -q "vim.opt.rtp:append('/opt/homebrew/opt/fzf')" "$nvim_config"; then
        log "Adding fzf to Neovim configuration..."
        echo "vim.opt.rtp:append('/opt/homebrew/opt/fzf')" >> "$nvim_config" || error "Failed to add fzf to Neovim config"
    fi
}

setup_config_file() {
    local filename="$1"
    local dotfiles_path="$DOTFILES_DIR/$filename"
    local home_path

    # ファイル名が既にドットで始まっているかチェック
    if [[ "$filename" == .* ]]; then
        home_path="$HOME_DIR/$filename"
    else
        home_path="$HOME_DIR/.$filename"
    fi

    log "Processing config file: $filename"
    log "dotfiles_path: $dotfiles_path"
    log "home_path: $home_path"

    if [ -f "$dotfiles_path" ]; then
        log "$filename exists in dotfiles directory"
        create_symlink "$dotfiles_path" "$home_path"
    else
        log "Error: $filename not found in dotfiles directory"
    fi

    log "Checking final state of $home_path:"
    if [ -L "$home_path" ]; then
        log "$home_path is a symlink pointing to $(readlink -f "$home_path")"
    elif [ -f "$home_path" ]; then
        log "$home_path is a regular file"
    else
        log "$home_path does not exist"
    fi
}

create_symlink() {
    local src="$1"
    local dest="$2"

    log "Creating symlink: $dest -> $src"

    if [ -e "$dest" ]; then
        if [ ! -L "$dest" ]; then
            log "Backing up $dest to $BACKUP_DIR"
            mkdir -p "$BACKUP_DIR"
            mv "$dest" "$BACKUP_DIR/" || error "Failed to backup $dest"
        else
            log "Removing existing symlink $dest"
            rm "$dest" || error "Failed to remove existing symlink $dest"
        fi
    fi

    ln -s "$src" "$dest" || error "Failed to create symlink from $src to $dest"
    
    log "Symlink creation result:"
    ls -l "$dest"
}

# 除外するファイルやディレクトリのパターン
EXCLUDE_PATTERNS=(
    ".git"
    ".gitignore"
    "README.md"
    "install.sh"
    "LICENSE"
    ".gitconfig_template"
    "generate_gitconfig.sh"
)

# preztoのインストール
install_prezto() {
    if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
        log "Installing prezto..."
        git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto" || error "Failed to install prezto"
    else
        log "prezto is already installed."
    fi
}

# powerline10kのインストール
install_powerline10k() {
    local powerline10k_dir="${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/external/powerlevel10k"
    if [ ! -d "$powerline10k_dir" ]; then
        log "Installing powerline10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$powerline10k_dir" || error "Failed to install powerline10k"
    else
        log "powerline10k is already installed."
    fi
}

# .gitconfigの生成
generate_gitconfig() {
    log "Generating .gitconfig..."
    source "$DOTFILES_DIR/generate_gitconfig.sh"
    generate_gitconfig "$DOTFILES_DIR" || error "Failed to generate .gitconfig"
}

# Neovimプラグインのインストール
install_neovim_plugins() {
    if command -v nvim >/dev/null 2>&1; then
        log "Installing Neovim plugins..."
        nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' || error "Failed to install Neovim plugins"
    else
        error "Neovim is not installed. Please install Neovim and run this script again."
    fi
}

process_directory() {
    local dir="$1"
    local rel_path="${dir#$DOTFILES_DIR/}"
    
    log "Processing directory: $dir"
    
    # 隠しファイルも含めて処理
    for item in "$dir"/* "$dir"/.[!.]*; do
        # ファイルが存在しない場合のエラーを回避
        [ -e "$item" ] || continue
        
        local item_rel_path="${item#$DOTFILES_DIR/}"
        local exclude=false

        log "Checking item: $item_rel_path"

        # 除外パターンをチェック
        for pattern in "${EXCLUDE_PATTERNS[@]}"; do
            if [[ "$item_rel_path" == $pattern* ]]; then
                exclude=true
                log "Item matches exclude pattern: $pattern"
                break
            fi
        done

        if [ "$exclude" = true ]; then
            log "Skipping excluded item: $item_rel_path"
            continue
        fi

        if [ -d "$item" ]; then
            log "Item is a directory, recursing into: $item_rel_path"
            process_directory "$item"
        elif [ -f "$item" ]; then
            log "Processing file: $item_rel_path"
            setup_config_file "$item_rel_path"
        else
            log "Unknown item type: $item_rel_path"
        fi
    done
}

# メイン処理
main() {
    log "Starting dotfiles installation..."

    log "Processing dotfiles..."
    process_directory "$DOTFILES_DIR"

    install_homebrew
    install_packages
    setup_neovim
    install_prezto
    install_powerline10k
    generate_gitconfig

    install_neovim_plugins

    log "Installation complete! Please restart your terminal or run 'source ~/.zshrc' to apply the changes."
    log "To customize your zsh prompt further, run 'p10k configure' after restarting your terminal."
}

# スクリプトの実行
main

