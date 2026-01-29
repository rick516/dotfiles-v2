eval "$(brew shellenv)"

# aqua (CLI version manager) - bun, pnpm等を管理
export AQUA_ROOT_DIR="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}"
export AQUA_GLOBAL_CONFIG="$HOME/dotfiles-v2/aqua.yaml"
export PATH="$AQUA_ROOT_DIR/bin:$PATH"

# Volta (Node.js version manager)
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Preztoの設定
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# テーマの設定 (preztoのpowerline10kテーマを使用)
zstyle ':prezto:module:prompt' theme 'powerlevel10k'

# Powerline10kの設定
# カスタマイズしたい場合は、`p10k configure` コマンドを実行してウィザードに従ってください
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# fzfの設定
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ディレクトリ移動のfuzzy検索
function fzf-cd() {
    local dir
    dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
}
alias fcd='fzf-cd'

# ファイル内容の検索関数
function fzf_rg_search() {
  if [ ! "$#" -gt 0 ]; then echo "検索語を入力してください"; return 1; fi
  local file
  file=$(rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}")
  if [[ -n "$file" ]]; then
    nvim "$file"
  fi
}

alias fs='fzf_rg_search'

# ファイル内検索 + 拡張子フィルター 
function fzf_rg_search_type() {
  if [ "$#" -lt 2 ]; then echo "使用法: fst 検索語 ファイルタイプ"; return 1; fi
  local file
  file=$(rg --type "$2" --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}")
  if [[ -n "$file" ]]; then
    nvim "$file"
  fi
}

alias fst='fzf_rg_search_type'

# 大文字小文字区別検索
function fzf_rg_search_case_sensitive() {
  if [ ! "$#" -gt 0 ]; then echo "検索語を入力してください"; return 1; fi
  local file
  file=$(rg --case-sensitive --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --pretty --context 10 '$1' || rg --pretty --context 10 '$1' {}")
  if [[ -n "$file" ]]; then
    nvim "$file"
  fi
}
alias fsc='fzf_rg_search_case_sensitive'

# SSH接続時に背景色を変更
if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
    zstyle ':prezto:module:prompt:powerlevel10k' preset 'remote'
else
    zstyle ':prezto:module:prompt:powerlevel10k' preset 'lean'
fi

# gitのエイリアス
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git checkout'
alias gb='git branch'
alias gg='git grep -n'
alias gcm='git commit -m'
alias gps='git push origin'
alias gpl='git pull origin'
alias gl='git log --oneline --graph --decorate'

# その他の便利なエイリアス
alias l='ls -lah'
alias lsa='ls -a'
alias ..='cd ..'
alias ...='cd ../..'
alias sz='source ~/.zshrc'

# AI CLI Tools
alias cdsp='claude --dangerously-skip-permissions'
alias oc='opencode'
alias cx='codex'

# nvimエイリアス
alias vim='nvim'
alias vi='nvim'
alias vimdiff='nvim -d'

# 補完の設定
autoload -Uz compinit && compinit

# 履歴の設定
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# zsh-autosuggestions 
zstyle ':prezto:module:autosuggestions' color 'yes'
zstyle ':prezto:module:autosuggestions:color' found ''

# zsh-syntax-highlighting 
zstyle ':prezto:module:syntax-highlighting' color 'yes'

# preztoモジュールの読み込み
zstyle ':prezto:load' pmodule \
  'environment' \
  'terminal' \
  'editor' \
  'history' \
  'directory' \
  'spectrum' \
  'utility' \
  'completion' \
  'prompt' \
  'git' \
  'syntax-highlighting' \
  'history-substring-search' \
  'autosuggestions'

# Powerline10kの即時プロンプト
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set Neovim as default editor
export EDITOR='nvim'
export VISUAL='nvim'

# Optional: Set Neovim as the default manpager
export MANPAGER='nvim +Man!'

# Optional: Use Neovim for viewing git diffs
export GIT_EDITOR='nvim'
[[ ! -f ${ZDOTDIR:-$HOME}/.p10k.zsh ]] || source ${ZDOTDIR:-$HOME}/.p10k.zsh

# シンタックスハイライトの設定
# 基本的な設定のみを適用し、エラーを回避する
() {
    # デフォルトのハイライトスタイルを設定
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
    
    # 基本的なスタイルのみを設定
    typeset -A ZSH_HIGHLIGHT_STYLES
    ZSH_HIGHLIGHT_STYLES[default]=none
    ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red
    ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=yellow
    ZSH_HIGHLIGHT_STYLES[alias]=fg=green
    ZSH_HIGHLIGHT_STYLES[builtin]=fg=green
    ZSH_HIGHLIGHT_STYLES[function]=fg=green
    ZSH_HIGHLIGHT_STYLES[command]=fg=green
    ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
    ZSH_HIGHLIGHT_STYLES[commandseparator]=none
    ZSH_HIGHLIGHT_STYLES[hashed-command]=fg=green
    ZSH_HIGHLIGHT_STYLES[path]=fg=cyan
    ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue
    ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=none
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=none
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=cyan
    ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=cyan
    ZSH_HIGHLIGHT_STYLES[assign]=none
}

# シンタックスハイライトを有効化
if [[ -f ${ZDOTDIR:-$HOME}/.zprezto/modules/syntax-highlighting/external/zsh-syntax-highlighting.zsh ]]; then
    source ${ZDOTDIR:-$HOME}/.zprezto/modules/syntax-highlighting/external/zsh-syntax-highlighting.zsh
else
    echo "警告: zsh-syntax-highlighting.zsh が見つかりません。シンタックスハイライトは無効です。" >&2
fi

# Neovimとターミナルを切り替えるエイリアス
alias nvim-toggle='nvim -c "ToggleTerm"'

# direnv
eval "$(direnv hook zsh)"

# .local/bin
export PATH="$HOME/.local/bin:$PATH"

# Rust/Cargo
. "$HOME/.cargo/env"

# bun completions (bun自体はaquaで管理)
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export PATH=$PATH:$HOME/.maestro/bin

# opencode
export PATH=__HOME__/.opencode/bin:$PATH
