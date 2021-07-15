export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH="/home/agregorevsky/.oh-my-zsh"

ZSH_THEME="cypher"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

alias cat="bat"
alias realcat="cat"
alias top="bashtop"
alias realtop="top"
