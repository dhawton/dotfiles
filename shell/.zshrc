# Check if fastfetch exists, and if so, run it
if command -v fastfetch >> /dev/null; then
  fastfetch
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
plugins=(git kubectl golang rust)
export ZSH_CUSTOM="$HOME/.oh-my-zsh-custom"
export ZSH_THEME="powerlevel10k/powerlevel10k"
export ZSH="/home/daniel/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Don't make the terminal use vim keybindings
bindkey -e

# Fuzzy Finder
source ~/.fzf.zsh

# History
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

# setup autocompletion
zstyle :compinstall filename "/home/daniel/.zshrc"
autoload -Uz compinit
compinit

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
. "$HOME"/.cargo/env

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
