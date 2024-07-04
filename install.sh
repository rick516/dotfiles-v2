#!/bin/bash

set -e

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Homebrewのインストール
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed."
    fi
}

# 必要なパッケージのインストール
install_packages() {
    echo "Installing necessary packages..."
    brew install fzf ripgrep neovim tmux zsh
    $(brew --prefix)/opt/fzf/install --all
}

# Neovimの設定ファイルにfzfの設定を追加
setup_nvim_fzf() {
    local nvim_config="$HOME/.config/nvim/init.vim"
    if [ -f "$nvim_config" ]; then
        if ! grep -q "set rtp+=/opt/homebrew/opt/fzf" "$nvim_config"; then
            echo "Adding fzf to Neovim configuration..."
            echo "set rtp+=/opt/homebrew/opt/fzf" >> "$nvim_config"
        fi
    else
        echo "Neovim configuration file not found. Please set up Neovim first."
    fi
}


# シンボリックリンクを作成する関数
create_symlink() {
    local src="$1"
    local dest="$2"
    local backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

    if [ -e "$dest" ]; then
        if [ ! -L "$dest" ]; then
            echo "Backing up $dest to $backup_dir"
            mkdir -p "$backup_dir"
            mv "$dest" "$backup_dir/"
        else
            rm "$dest"
        fi
    fi

    echo "Creating symlink: $dest -> $src"
    ln -s "$src" "$dest"
}

# 除外するファイルやディレクトリのパターン
EXCLUDE_PATTERNS=(
    ".git"
    ".gitignore"
    "README.md"
    "install.sh"
    "LICENSE"
    ".gitconfig_tepmlate"
    "generate_gitconfig.sh"
)

# dotfilesディレクトリ内のファイルを再帰的に処理
process_directory() {
    local dir="$1"
    local rel_path="${dir#$DOTFILES_DIR/}"
    
    for item in "$dir"/*; do
        local item_rel_path="${item#$DOTFILES_DIR/}"
        local exclude=false

        # 除外パターンをチェック
        for pattern in "${EXCLUDE_PATTERNS[@]}"; do
            if [[ "$item_rel_path" == $pattern* ]]; then
                exclude=true
                break
            fi
        done

        if [ "$exclude" = true ]; then
            echo "Skipping excluded item: $item_rel_path"
            continue
        fi

        if [ -d "$item" ]; then
            process_directory "$item"
        elif [ -f "$item" ]; then
            local dest="$HOME/$item_rel_path"
            create_symlink "$item" "$dest"
        fi
    done
}

# シンボリックリンクの作成
echo "Creating symlinks..."
process_directory "$DOTFILES_DIR"

# 必要なライブラリのインストールおよびセットアップ
install_homebrew
install_packages
setup_nvim_fzf

# preztoのインストール
if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
fi

# powerline10kのインストール（preztoに含まれていない場合）
if [ ! -d ${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/external/powerlevel10k ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/external/powerlevel10k
fi

# .gitconfigの生成
source "$DOTFILES_DIR/generate_gitconfig.sh"
generate_gitconfig "$DOTFILES_DIR"

# Neovimプラグインのインストール
if command -v nvim >/dev/null 2>&1; then
    echo "Installing Neovim plugins..."
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
else
    echo "Neovim is not installed. Please install Neovim and run this script again."
fi


# preztoの設定ファイルのシンボリックリンクを作成
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/*; do
  if [ "$(basename "$rcfile")" != "README.md" ]; then
    create_symlink "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile##*/}"
  fi
done

echo "Installation complete! Please restart your terminal or run 'source ~/.zshrc' to apply the changes."
echo "To customize your zsh prompt further, run 'p10k configure' after restarting your terminal."
