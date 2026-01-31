#!/bin/bash
# dotfiles-v2 installer
# 冪等性あり（何度実行しても同じ結果）

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# =============================================================================
# Utilities
# =============================================================================

log() { echo "[$(date +'%H:%M:%S')] $1"; }
error() { log "ERROR: $1" >&2; exit 1; }

create_symlink() {
    local src="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        log "Backing up: $dest"
        mkdir -p "$BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/"
    elif [ -L "$dest" ]; then
        rm "$dest"
    fi

    ln -s "$src" "$dest"
    log "Linked: $(basename "$dest")"
}

# =============================================================================
# Package Installation (冪等)
# =============================================================================

install_homebrew() {
    if command -v brew &>/dev/null; then
        log "Homebrew: already installed"
        return
    fi
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(brew shellenv)"
}

install_aqua() {
    if ! command -v aqua &>/dev/null; then
        log "Installing aqua..."
        brew install aquaproj/aqua/aqua
    else
        log "aqua: already installed"
    fi

    # aqua PATH設定（Homebrew経由のaquaも含む）
    export AQUA_ROOT_DIR="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}"
    export PATH="$AQUA_ROOT_DIR/bin:$(brew --prefix)/bin:$PATH"
    export AQUA_GLOBAL_CONFIG="$DOTFILES_DIR/aqua.yaml"

    log "Installing CLI tools via aqua..."
    aqua install || log "Warning: Some aqua packages failed to install"
}

install_rust() {
    if command -v rustc &>/dev/null; then
        log "Rust: already installed"
        return
    fi
    log "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
}

install_volta() {
    if command -v volta &>/dev/null; then
        log "Volta: already installed"
        return
    fi
    log "Installing Volta..."
    curl https://get.volta.sh | bash -s -- --skip-setup
}

install_ghostty() {
    if [ -d "/Applications/Ghostty.app" ] || brew list --cask ghostty &>/dev/null 2>&1; then
        log "Ghostty: already installed"
        return
    fi
    log "Installing Ghostty..."
    brew install --cask ghostty || log "Warning: Ghostty installation failed"
}

install_fonts() {
    if brew list --cask font-plemol-jp-nf &>/dev/null 2>&1; then
        log "PlemolJP Nerd Font: already installed"
        return
    fi
    log "Installing PlemolJP Nerd Font..."
    brew install --cask font-plemol-jp-nf || log "Warning: Font installation failed"
}

install_docker() {
    if [ -d "/Applications/Docker.app" ] || brew list --cask docker &>/dev/null 2>&1; then
        log "Docker Desktop: already installed"
        return
    fi
    log "Installing Docker Desktop..."
    brew install --cask docker || log "Warning: Docker installation failed"
}

install_aws_vault() {
    if brew list --cask aws-vault &>/dev/null 2>&1; then
        log "aws-vault: already installed"
        return
    fi
    log "Installing aws-vault..."
    brew install --cask aws-vault || log "Warning: aws-vault installation failed"
}

install_keifu() {
    if command -v keifu &>/dev/null; then
        log "keifu: already installed"
        return
    fi
    if command -v cargo &>/dev/null; then
        log "Installing keifu..."
        cargo install keifu
    else
        log "Warning: cargo not found, skipping keifu"
    fi
}

# =============================================================================
# AI CLI Tools
# =============================================================================

install_opencode() {
    if command -v opencode &>/dev/null; then
        log "opencode: already installed"
        return
    fi
    log "Installing opencode..."
    brew tap opencode-ai/tap
    brew install opencode-ai/tap/opencode
}

install_claude_code() {
    if command -v claude &>/dev/null; then
        log "Claude Code: already installed"
        return
    fi
    log "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
}

install_codex() {
    if command -v codex &>/dev/null; then
        log "Codex CLI: already installed"
        return
    fi
    # bunでインストール（aquaで管理）
    if command -v bun &>/dev/null; then
        log "Installing Codex CLI via bun..."
        bun install -g @openai/codex
    else
        log "Warning: bun not found, skipping codex installation"
    fi
}

# =============================================================================
# Shell Setup
# =============================================================================

setup_prezto() {
    local prezto_dir="${ZDOTDIR:-$HOME}/.zprezto"
    if [ -d "$prezto_dir" ]; then
        log "prezto: already installed"
        return
    fi
    log "Installing prezto..."
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "$prezto_dir"
}

setup_powerlevel10k() {
    local p10k_dir="${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/external/powerlevel10k"
    if [ -d "$p10k_dir" ]; then
        log "powerlevel10k: already installed"
        return
    fi
    log "Installing powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
}

# =============================================================================
# Dotfiles Setup
# =============================================================================

setup_dotfiles() {
    log "Setting up dotfiles..."

    # Shell configs (from shell/ directory)
    if [ -d "$DOTFILES_DIR/shell" ]; then
        for file in "$DOTFILES_DIR/shell"/.*; do
            [ -f "$file" ] && create_symlink "$file" "$HOME/$(basename "$file")"
        done
    fi

    # AI CLI configs (from ai/ directory)
    [ -f "$DOTFILES_DIR/ai/.opencode.json" ] && create_symlink "$DOTFILES_DIR/ai/.opencode.json" "$HOME/.opencode.json"
    # Claude Code: skillsだけ管理（cache/debug等は実行時生成）
    if [ -d "$DOTFILES_DIR/ai/claude/skills" ]; then
        mkdir -p "$HOME/.claude"
        create_symlink "$DOTFILES_DIR/ai/claude/skills" "$HOME/.claude/skills"
    fi

    # .config directories (ghostty/zellijは__HOME__展開が必要なのでコピー)
    if [ -d "$DOTFILES_DIR/.config" ]; then
        for config_dir in "$DOTFILES_DIR/.config"/*; do
            [ -d "$config_dir" ] || continue
            local dir_name=$(basename "$config_dir")
            if [[ "$dir_name" == "ghostty" || "$dir_name" == "zellij" ]]; then
                # コピーして__HOME__を展開
                log "Copying and expanding: $dir_name"
                rm -rf "$HOME/.config/$dir_name"
                cp -r "$config_dir" "$HOME/.config/$dir_name"
                find "$HOME/.config/$dir_name" -type f -exec sed -i '' "s|__HOME__|$HOME|g" {} \;
            else
                create_symlink "$config_dir" "$HOME/.config/$dir_name"
            fi
        done
    fi

    # .local/bin scripts
    if [ -d "$DOTFILES_DIR/.local/bin" ]; then
        mkdir -p "$HOME/.local/bin"
        for script in "$DOTFILES_DIR/.local/bin"/*; do
            [ -f "$script" ] && create_symlink "$script" "$HOME/.local/bin/$(basename "$script")"
        done
    fi
}

setup_ghostty_config() {
    local src="$DOTFILES_DIR/.config/ghostty/config"
    local dest="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
    if [ -f "$src" ]; then
        log "Copying and expanding ghostty config to Library"
        mkdir -p "$(dirname "$dest")"
        [ -L "$dest" ] && rm "$dest"
        cp "$src" "$dest"
        sed -i '' "s|__HOME__|$HOME|g" "$dest"
    fi
}

setup_fzf() {
    local fzf_install="$(brew --prefix 2>/dev/null)/opt/fzf/install"
    if [ -f "$fzf_install" ] && [ ! -f "$HOME/.fzf.zsh" ]; then
        log "Setting up fzf key bindings..."
        "$fzf_install" --no-update-rc --key-bindings --completion
    fi
}

setup_gitconfig() {
    if [ -f "$HOME/.gitconfig" ]; then
        log ".gitconfig: already exists"
        return
    fi
    if [ -f "$DOTFILES_DIR/scripts/generate_gitconfig.sh" ]; then
        log "Generating .gitconfig..."
        source "$DOTFILES_DIR/scripts/generate_gitconfig.sh"
    fi
}

install_neovim_plugins() {
    if ! command -v nvim &>/dev/null; then
        log "Neovim not found, skipping plugin installation"
        return
    fi
    log "Installing Neovim plugins..."
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' 2>/dev/null || true
    nvim --headless -c 'PackerInstall' -c 'qa!' 2>/dev/null || true
    log "Neovim plugins: done"
}

# =============================================================================
# Main
# =============================================================================

main() {
    log "======================================"
    log "  dotfiles-v2 installer"
    log "======================================"
    echo ""

    # 1. Package managers
    log "--- Package Managers ---"
    install_homebrew
    install_aqua

    # 2. Language toolchains
    log "--- Language Toolchains ---"
    install_rust
    install_volta

    # 3. GUI apps & cargo tools
    log "--- Applications ---"
    install_ghostty
    install_fonts
    install_docker
    install_aws_vault
    install_keifu

    # 4. AI CLI Tools
    log "--- AI CLI Tools ---"
    install_opencode
    install_claude_code
    install_codex

    # 5. Shell frameworks
    log "--- Shell Setup ---"
    setup_prezto
    setup_powerlevel10k

    # 6. Dotfiles
    log "--- Dotfiles ---"
    setup_dotfiles
    setup_ghostty_config
    setup_fzf
    setup_gitconfig

    # 7. Editor plugins
    log "--- Editor Plugins ---"
    install_neovim_plugins

    echo ""
    log "======================================"
    log "  Installation complete!"
    log "======================================"
    echo ""
    log "Next steps:"
    log "  1. Restart your terminal (or run: exec zsh -l)"
    log "  2. Run 'p10k configure' to customize prompt (optional)"
    echo ""
    log "======================================"
    log "  TODO: Setup API Keys"
    log "======================================"
    echo ""
    log "Create ~/.envrc with your API keys:"
    echo ""
    echo '  cat > ~/.envrc << '\''EOF'\'''
    echo '  # API Keys (managed by direnv)'
    echo '  '
    echo '  # Productivity'
    echo '  export NOTION_API_KEY="your-notion-api-key"'
    echo '  export SLACK_WEBHOOK_URL="your-slack-webhook-url"'
    echo '  '
    echo '  # AI Services'
    echo '  export GEMINI_API_KEY="your-gemini-api-key"'
    echo '  export CONTEXT7_API_KEY="your-context7-api-key"'
    echo '  export XAI_API_KEY="your-xai-api-key"'
    echo '  export ZAI_API_KEY="your-zai-api-key"'
    echo '  EOF'
    echo ""
    log "Then run: cd ~ && direnv allow"
    echo ""
}

main "$@"
