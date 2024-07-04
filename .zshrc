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
alias gc='git commit -m'
alias gps='git push origin'
alias gl='git log --oneline --graph --decorate'

# その他の便利なエイリアス
alias l='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'

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
