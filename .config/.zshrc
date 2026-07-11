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

source $ZSH/oh-my-zsh.sh

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

# ==========================================
# 履歴
# ==========================================
HISTSIZE=10000
SAVEHIST=10000
setopt share_history

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# nvm 設定
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="/mnt/c/tools/zenhan/zenhan/bin64:$PATH"
