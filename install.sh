#!/bin/bash

#!/bin/bash

set -e

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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

# tmuxのインストール
install_tmux() {
    if ! command -v tmux &> /dev/null; then
        echo "tmux is not installed. Installing tmux..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y tmux
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y tmux
            elif command -v pacman &> /dev/null; then
                sudo pacman -S tmux
            else
                echo "Unsupported package manager. Please install tmux manually."
                return 1
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            if command -v brew &> /dev/null; then
                brew install tmux
            else
                echo "Homebrew not found. Please install Homebrew and try again."
                return 1
            fi
        else
            echo "Unsupported operating system. Please install tmux manually."
            return 1
        fi
    else
        echo "tmux is already installed."
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

# tmuxのインストールと設定
install_tmux
if [ $? -eq 0 ]; then
    create_symlink "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
    echo "tmux configuration has been set up."
else
    echo "Failed to set up tmux. Please install tmux manually and run this script again."
fi

# シンボリックリンクの作成
echo "Creating symlinks..."
process_directory "$DOTFILES_DIR"

# .gitconfigの生成
source "$DOTFILES_DIR/generate_gitconfig.sh"
generate_gitconfig "$DOTFILES_DIR"

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
