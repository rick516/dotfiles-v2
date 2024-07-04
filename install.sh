#!/bin/bash

# dotfilesディレクトリへ移動
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DOTFILES_DIR"

# バックアップ用ディレクトリ
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# シンボリックリンクを作成する関数
create_symlink() {
    local src="$1"
    local dest="$2"
    local backup="$BACKUP_DIR/${dest##*/}"

    if [ -e "$dest" ]; then
        if [ ! -L "$dest" ]; then
            echo "Backing up $dest to $backup"
            mkdir -p "$(dirname "$backup")"
            mv "$dest" "$backup"
        else
            rm "$dest"
        fi
    fi

    echo "Creating symlink: $dest -> $src"
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
}

# Neovimのインストール
install_neovim() {
    if ! command -v nvim &> /dev/null; then
        echo "Neovim is not installed. Installing Neovim..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y neovim
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y neovim
            elif command -v pacman &> /dev/null; then
                sudo pacman -S neovim
            else
                echo "Unsupported package manager. Please install Neovim manually."
                return 1
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            if command -v brew &> /dev/null; then
                brew install neovim
            else
                echo "Homebrew not found. Please install Homebrew and try again."
                return 1
            fi
        else
            echo "Unsupported operating system. Please install Neovim manually."
            return 1
        fi
    else
        echo "Neovim is already installed."
    fi
}

# preztoのインストール
if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
fi

# fzfのインストール
if [ ! -d ~/.fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
fi

# powerline10kのインストール（preztoに含まれていない場合）
if [ ! -d ${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/external/powerlevel10k ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/external/powerlevel10k
fi

# Neovimのインストール
install_neovim

# symlinks.txtからシンボリックリンクを作成
while IFS=: read -r src dest
do
    create_symlink "$DOTFILES_DIR/$src" "$HOME/$dest"
done < symlinks.txt

# preztoの設定ファイルのシンボリックリンクを作成
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/*; do
  if [ "$(basename "$rcfile")" != "README.md" ]; then
    create_symlink "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile##*/}"
  fi
done

# Neovimプラグインのインストール
if command -v nvim >/dev/null 2>&1; then
    echo "Installing Neovim plugins..."
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
else
    echo "Neovim is not installed. Please install Neovim and run this script again."
fi

echo "Installation complete! Please restart your terminal or run 'source ~/.zshrc' to apply the changes."
echo "To customize your zsh prompt further, run 'p10k configure' after restarting your terminal."
