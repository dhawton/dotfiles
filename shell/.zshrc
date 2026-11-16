# Add deno completions to search path
if [[ ":$FPATH:" != *":/home/daniel/.zsh/completions:"* ]]; then export FPATH="/home/daniel/.zsh/completions:$FPATH"; fi
# Check if fastfetch exists, and if so, run it
if command -v fastfetch >> /dev/null; then
  fastfetch
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
plugins=(dh-git kubectl golang rust)
export ZSH_CUSTOM="$HOME/.oh-my-zsh-custom"
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  export ZSH_THEME=""
else
  export ZSH_THEME="powerlevel10k/powerlevel10k"
fi
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

# pnpm
export PNPM_HOME="/home/daniel/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun completions
[ -s "/home/daniel/.bun/_bun" ] && source "/home/daniel/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="/home/daniel/.config/herd-lite/bin:$PATH"
export PHP_INI_SCAN_DIR="/home/daniel/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"

# composer
export PATH="$HOME/.config/composer/vendor/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
fi
export LESS="-F -X $LESS"
export GOPRIVATE=github.com/solo-io

alias lfrpdb="mariadb --host 127.0.0.1 -u lfrp -p --ssl=0"
. "/home/daniel/.deno/env"

# nightly `deno upgrade` (machine-local; guarded so it's a no-op elsewhere)
[[ -f "$HOME/.config/deno-nightly/hook.zsh" ]] && . "$HOME/.config/deno-nightly/hook.zsh"

# Flutter and Android: Flutter in ~/development/flutter, the Android SDK in
# ~/Android/Sdk, JDK 17 for Gradle.
export ANDROID_HOME="$HOME/Android/Sdk"
export JAVA_HOME="/usr/lib64/jvm/java-17-openjdk"
export PATH="$HOME/development/flutter/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
