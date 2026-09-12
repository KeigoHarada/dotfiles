# ==========================================
# PATH 設定 (重複排除 & 存在チェック)
# ==========================================
# path 配列と PATH 環境変数の重複を自動的に排除
typeset -U path PATH

# 優先配置するパス (存在する場合のみ追加)
path=(
  $HOME/.local/bin(N)
  /opt/homebrew/bin(N)
  /opt/homebrew/sbin(N)
  $path
)

# ==========================================
# Oh My Zsh
# ==========================================
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"

plugins=(
  git
  z
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf
)

[ -s "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# ==========================================
# 環境変数
# ==========================================
export LANG=ja_JP.UTF-8
export EDITOR=vim

# ==========================================
# エイリアス
# ==========================================
alias ll='ls -la'
alias la='ls -a'
alias ..='cd ..'
alias ...='cd ../..'
alias g='git'
alias c='clear'

# ターミナルマルチプレクサ (Herdrへ移行中)
alias hd='herdr'

# ==========================================
# 履歴
# ==========================================
HISTSIZE=10000
SAVEHIST=10000
setopt share_history

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# nvm 設定
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# pnpm 設定
if [ -d "$HOME/Library/pnpm" ]; then
  export PNPM_HOME="$HOME/Library/pnpm"
elif [ -d "$HOME/.local/share/pnpm" ]; then
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
[ -n "$PNPM_HOME" ] && path=($PNPM_HOME $path)

# ==========================================
# PATH クリーンアップ
# ==========================================
# 存在しないディレクトリを PATH から一括除外 (死んだパスの除去)
path=($^path(N-/))
