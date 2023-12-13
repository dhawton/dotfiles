# Powerlevel10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
export ZSH_THEME="powerlevel10k/powerlevel10k"
export ZSH="$HOME/.oh-my-zsh"
plugins=(git kubectl)
source $ZSH/oh-my-zsh.sh
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

. "$HOME"/.asdf/asdf.sh
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit