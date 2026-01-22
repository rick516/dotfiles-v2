#!/bin/bash

generate_gitconfig() {
    local dotfiles_dir="$1"
    local template="$dotfiles_dir/.gitconfig_template"
    local target="$HOME/.gitconfig"

    if [ ! -f "$target" ]; then
        echo "Generating .gitconfig..."
        read -p "Enter your Git username: " git_name
        read -p "Enter your Git email: " git_email

        sed -e "s/YOUR_NAME/$git_name/" -e "s/YOUR_EMAIL/$git_email/" "$template" > "$target"
        echo ".gitconfig has been generated at $target"
    else
        echo ".gitconfig already exists. Skipping generation."
    fi
}

# スクリプトが直接実行された場合のみ実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    generate_gitconfig "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi
