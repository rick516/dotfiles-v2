#!/bin/bash

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SYMLINKS_FILE="$DOTFILES_DIR/symlinks.txt"

# シンボリックリンクのエントリを追加する関数
add_symlink_entry() {
    local src="$1"
    local dest="$2"
    echo "$src:$dest" >> "$SYMLINKS_FILE"
    echo "Added new entry: $src -> $dest"
}

# symlinks.txtの既存エントリをチェックする関数
check_existing_entry() {
    local src="$1"
    grep -q "^$src:" "$SYMLINKS_FILE"
    return $?
}

# dotfilesディレクトリ内のファイルを再帰的に処理
process_directory() {
    local dir="$1"
    local rel_path="${dir#$DOTFILES_DIR/}"
    
    for item in "$dir"/*; do
        if [ -d "$item" ]; then
            process_directory "$item"
        elif [ -f "$item" ]; then
            local file_rel_path="${item#$DOTFILES_DIR/}"
            if [[ "$file_rel_path" != .git* ]] && [[ "$file_rel_path" != *.sh ]] && ! check_existing_entry "$file_rel_path"; then
                read -p "Add $file_rel_path to symlinks? (y/n): " answer
                if [[ $answer == [Yy]* ]]; then
                    add_symlink_entry "$file_rel_path" "$file_rel_path"
                fi
            fi
        fi
    done
}

# メイン処理
echo "Updating symlinks.txt..."
process_directory "$DOTFILES_DIR"
echo "Update complete. Please review $SYMLINKS_FILE for any manual adjustments."
