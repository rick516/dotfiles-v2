#!/bin/bash
# ディレクトリ名は/dotfiles-v2です。

set -e

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$HOME/dotfiles-v2/backups/$(date +%Y%m%d_%H%M%S)"

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

    # Packerのインストール
    local packer_dir="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
    if [ ! -d "$packer_dir" ]; then
        log "Installing Packer..."
        git clone --depth 1 https://github.com/wbthomason/packer.nvim "$packer_dir" || error "Failed to install Packer"
    fi

    log "Creating Neovim configuration file..."
    cat << EOF > "$nvim_config"
-- Basic Neovim configuration
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2

-- Ensure Packer is installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Packer setup
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  -- Add your plugins here
end)

if packer_bootstrap then
  require('packer').sync()
end

vim.opt.rtp:append('/opt/homebrew/opt/fzf')
EOF

    log "Neovim configuration file created at $nvim_config"
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

# シンボリックリンクを作成する関数
create_symlink() {
    local src="$1"
    local dest="$2"

    log "Creating symlink: $dest -> $src"

    # 親ディレクトリが存在しない場合は作成
    mkdir -p "$(dirname "$dest")"

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
    "cleanup.sh"
    "backups"
)

# preztoのインストールと設定
# アンインストールするなら　$ rm -rf ~/.zprezto ~/.zlogin ~/.zlogout ~/.zpreztorc ~/.zprofile ~/.zshenv ~/.zshrc
install_prezto() {
    if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
        log "Installing prezto..."
        git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto" || error "Failed to install prezto"
    else
        log "Updating prezto..."
        cd "${ZDOTDIR:-$HOME}/.zprezto" && git pull && git submodule update --init --recursive
    fi

    # preztoの設定ファイルの処理
    local prezto_files=("zlogin" "zlogout" "zpreztorc" "zprofile" "zshenv" "zshrc")
    for file in "${prezto_files[@]}"; do
        local dotfiles_path="$DOTFILES_DIR/.$file"
        local home_path="${ZDOTDIR:-$HOME}/.$file"
        local prezto_path="${ZDOTDIR:-$HOME}/.zprezto/runcoms/$file"

        if [ ! -f "$dotfiles_path" ]; then
            log "Copying $file from prezto to dotfiles"
            cp "$prezto_path" "$dotfiles_path"
        fi
        create_symlink "$dotfiles_path" "$home_path"
    done

    # preztoのプロンプト設定を確認
    local zpreztorc="${ZDOTDIR:-$HOME}/.zpreztorc"
    if [ ! -f "$zpreztorc" ]; then
        error ".zpreztorc file not found"
    fi
}

# powerline10kのインストールとセットアップ
install_powerline10k() {
    local powerline10k_dir="${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/external/powerlevel10k"
    if [ ! -d "$powerline10k_dir" ]; then
        log "Installing powerline10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$powerline10k_dir" || error "Failed to install powerline10k"
    else
        log "powerline10k is already installed."
    fi

    # .zpreztorc ファイルを更新
    local zpreztorc="$DOTFILES_DIR/.zpreztorc"
    if [ -f "$zpreztorc" ]; then
        if ! grep -q "zstyle ':prezto:module:prompt' theme 'powerlevel10k'" "$zpreztorc"; then
            log "Updating .zpreztorc with powerlevel10k theme..."
            echo "zstyle ':prezto:module:prompt' theme 'powerlevel10k'" >> "$zpreztorc"
        fi
    else
        error ".zpreztorc file not found in dotfiles"
    fi

    # .zshrc ファイルを更新
    local zshrc="$DOTFILES_DIR/.zshrc"
    if [ -f "$zshrc" ]; then
        if ! grep -q "source \${ZDOTDIR:-\$HOME}/.p10k.zsh" "$zshrc"; then
            log "Updating .zshrc with p10k configuration..."
            echo "[[ ! -f \${ZDOTDIR:-\$HOME}/.p10k.zsh ]] || source \${ZDOTDIR:-\$HOME}/.p10k.zsh" >> "$zshrc"
        fi
    else
        error ".zshrc file not found in dotfiles"
    fi

    # p10k.zsh ファイルの処理
    local p10k_dotfiles="$DOTFILES_DIR/.p10k.zsh"
    local p10k_home="${ZDOTDIR:-$HOME}/.p10k.zsh"
    if [ ! -f "$p10k_dotfiles" ]; then
        log "Creating default p10k.zsh in dotfiles"
        # デフォルトのp10k設定を生成
        cat << 'EOF' > "$p10k_dotfiles"
# Generated by Powerlevel10k configuration wizard on 2024-07-05 at 16:00 UTC.
# Based on romkatv/powerlevel10k/config/p10k-lean.zsh, checksum 03575.
# Wizard options: powerline, lean, 2 lines, compact, instant_prompt=verbose.
# Type `p10k configure` to generate another config.
#
# Config file for Powerlevel10k with the style of Pure (https://github.com/sindresorhus/pure).
#
# Temporarily disable instant prompt. If you want to keep instant prompt enabled,
# remove these lines.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Powerlevel10k configurations...
# (ここに長いPowerlevel10kの設定が続きます。省略のため一部のみ表示しています。)

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
    fi
    create_symlink "$p10k_dotfiles" "$p10k_home"

    log "Powerlevel10k has been set up with a default configuration. You can customize it further by running 'p10k configure' if needed."
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
        nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' || log "Warning: PackerSync might have failed, but continuing..."
        nvim --headless -c 'PackerInstall' -c 'qa!'
    else
        error "Neovim is not installed. Please install Neovim and run this script again."
    fi
}

# dotfilesディレクトリ内のファイルを再帰的に処理
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
            # .zpreztoディレクトリ内のファイルは処理しない
            if [[ "$item_rel_path" != .zprezto/* ]]; then
                log "Processing file: $item_rel_path"
                setup_config_file "$item_rel_path"
            else
                log "Skipping .zprezto file: $item_rel_path"
            fi
        else
            log "Unknown item type: $item_rel_path"
        fi
    done
}

# メイン処理
main() {
    log "Starting dotfiles installation..."

    install_homebrew
    install_packages
    setup_neovim
    install_prezto
    install_powerline10k

    log "Processing dotfiles..."
    process_directory "$DOTFILES_DIR"

    generate_gitconfig
    install_neovim_plugins

    log "Installation complete! Please restart your terminal or run 'source ~/.zshrc' to apply the changes."
    log "To customize your zsh prompt further, run 'p10k configure' after restarting your terminal."
}

# スクリプトの実行
main

log "Applying Powerlevel10k theme..."
source ${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/external/powerlevel10k/powerlevel10k.zsh-theme

log "Reloading zsh configuration..."
exec zsh -l
