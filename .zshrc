eval "$(/opt/homebrew/bin/brew shellenv)"
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
alias ..='cd ..'
alias ...='cd ../..'
alias sz='source ~/.zshrc'

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
