export ZSH="$HOME/.oh-my-sh"
ZSH_THEME="agnoster"

plugins=(
  git
  z
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf
)

source $ZSH/oh-my-zsh.sh

export LANG=ja_JP.UTF-8
export EDITOR=vim

alias ll='ls -la'
alias la='ls -a'
alias ..='cd ..'
alias ...='cd ../../'
alias g='git'
alias c='clear'

HISTSIZE=10000
SAVEHIST=10000
setopt share_history

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
