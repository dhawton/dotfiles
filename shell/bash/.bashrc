# ~/.bashrc (symlink to dotfiles/shell/bash/.bashrc). Replaces the old zsh + oh-my-zsh + powerlevel10k setup.
#
# Part 1 sets up the environment (PATH, tools). Every bash reads it, also scripts and AI tools.
# Part 2 is only for a person at a terminal: prompt (starship), ble.sh, history, completion, fastfetch.
# AI tools (Claude Code sets CLAUDECODE=1) and terminals without a TTY get part 1, aliases and functions only.

# Load once per shell (some systems read ~/.bashrc from /etc/profile and ~/.profile too). Not exported, so a new
# bash started from this one loads it again.
[[ -n "${__dotfiles_bashrc:-}" ]] && return
__dotfiles_bashrc=1

# The folder this file really lives in (~/.bashrc is a symlink to it).
DOTFILES_BASH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

_path_prepend() { case ":$PATH:" in *":$1:"*) ;; *) [[ -d "$1" ]] && PATH="$1:$PATH" ;; esac; }
_path_append() { case ":$PATH:" in *":$1:"*) ;; *) [[ -d "$1" ]] && PATH="$PATH:$1" ;; esac; }

# --- Part 1: environment -----------------------------------------------------------------------------------------

if [[ -z "${HOMEBREW_PREFIX:-}" ]]; then
  for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
    [[ -x "$_brew" ]] && eval "$("$_brew" shellenv)" && break
  done
  unset _brew
fi
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
[[ -f "$HOME/.deno/env" ]] && . "$HOME/.deno/env"

export EDITOR=nvim VISUAL=nvim
export BASH_SILENCE_DEPRECATION_WARNING=1 # macOS: no "the default shell is now zsh" note
export LESS="-F -X $LESS"
export GOPRIVATE=github.com/solo-io
export GOPATH="$HOME/go"

_path_append /usr/local/go/bin
_path_append "$HOME/go/bin"
_path_append "$HOME/.local/bin"
_path_prepend "${KREW_ROOT:-$HOME/.krew}/bin"
_path_prepend "$HOME/.yarn/bin"
_path_prepend "$HOME/.config/yarn/global/node_modules/.bin"
export PNPM_HOME="$HOME/.local/share/pnpm"
_path_prepend "$PNPM_HOME"
export BUN_INSTALL="$HOME/.bun"
_path_prepend "$BUN_INSTALL/bin"
_path_prepend "$HOME/.config/herd-lite/bin"
export PHP_INI_SCAN_DIR="$HOME/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"
_path_prepend "$HOME/.config/composer/vendor/bin"
# Homebrew's libpq (psql, pg_dump) is keg-only on macOS.
[[ -n "${HOMEBREW_PREFIX:-}" ]] && _path_append "$HOMEBREW_PREFIX/opt/libpq/bin"

# Flutter and Android SDK.
export ANDROID_HOME="$HOME/Android/Sdk"
[[ -d /usr/lib64/jvm/java-17-openjdk ]] && export JAVA_HOME="/usr/lib64/jvm/java-17-openjdk"
_path_prepend "$ANDROID_HOME/emulator"
_path_prepend "$ANDROID_HOME/platform-tools"
_path_prepend "$ANDROID_HOME/cmdline-tools/latest/bin"
_path_prepend "$HOME/development/flutter/bin"

[[ -f "$HOME/google-cloud-sdk/path.bash.inc" ]] && . "$HOME/google-cloud-sdk/path.bash.inc"

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"

export PATH

# Aliases and functions (git, kubectl, your own). Bash only expands aliases in interactive shells.
[[ -f "$DOTFILES_BASH/functions.bash" ]] && . "$DOTFILES_BASH/functions.bash"
[[ -f "$DOTFILES_BASH/aliases.bash" ]] && . "$DOTFILES_BASH/aliases.bash"

# --- Part 2: a person at a terminal ------------------------------------------------------------------------------

[[ $- == *i* ]] || return
# Part 2 needs bash 4+ (macOS's /bin/bash is 3.2: use Homebrew's bash, see install.sh).
((BASH_VERSINFO[0] >= 4)) || return
[[ -z "${CLAUDECODE:-}" && -t 0 && -t 1 && "${TERM:-dumb}" != dumb ]] || return

# ble.sh (zsh-like editing: grey suggestions, colors, menus). Loaded first, attached at the end.
_blesh="$HOME/.local/share/blesh/ble.sh"
[[ -f "$_blesh" ]] && . "$_blesh" --noattach --rcfile "$DOTFILES_BASH/blerc"

command -v fastfetch >/dev/null && fastfetch

# History: big, no duplicates, shared between terminals (ble.sh shares it live; without it, on each prompt).
HISTFILE="$HOME/.bash_history"
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T '
shopt -s histappend cmdhist histverify
[[ -z "${BLE_VERSION:-}" ]] && PROMPT_COMMAND="history -a; history -n${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# zsh-like behavior: type a folder name to cd into it, fix small typos in cd, ** matches subfolders.
shopt -s autocd cdspell dirspell globstar checkwinsize extglob

# Completion: bash-completion (Homebrew's, else the system one), then fzf (Ctrl+R history, Ctrl+T files, Alt+C folders).
if [[ -n "${HOMEBREW_PREFIX:-}" && -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]]; then
  . "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
elif [[ -r /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
fi
[[ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]] && . "$HOME/google-cloud-sdk/completion.bash.inc"
[[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"
if [[ -f "$HOME/.fzf.bash" ]]; then
  . "$HOME/.fzf.bash"
elif command -v fzf >/dev/null; then
  eval "$(fzf --bash 2>/dev/null)"
fi

# Completion for the aliases: g and every "git <sub>" alias complete like git; k* like kubectl.
# bash-completion loads git and kubectl completion on first use; load them now so the aliases can use them.
for _c in git kubectl; do
  if declare -F _comp_load >/dev/null; then
    _comp_load "$_c" 2>/dev/null
  elif declare -F __load_completion >/dev/null; then
    __load_completion "$_c" 2>/dev/null
  fi
done
unset _c
if declare -F __git_complete >/dev/null; then
  __git_complete g __git_main
  for _a in "${!BASH_ALIASES[@]}"; do
    _v=${BASH_ALIASES[$_a]}
    if [[ $_v =~ ^git\ ([a-z-]+) ]]; then
      _f="_git_${BASH_REMATCH[1]//-/_}"
      declare -F "$_f" >/dev/null && __git_complete "$_a" "$_f"
    fi
  done
fi
if declare -F __start_kubectl >/dev/null; then
  complete -o default -F __start_kubectl k
  for _a in "${!BASH_ALIASES[@]}"; do
    [[ ${BASH_ALIASES[$_a]} == kubectl\ * ]] && complete -o default -F __start_kubectl "$_a"
  done
fi
unset _a _v _f

# ssh-agent: keep the one we have (herdr, Windows), else start one and add the key.
ssh-add -l >/dev/null 2>&1
if [[ $? -eq 2 ]]; then # 2 = no agent (1 = agent without keys, 0 = agent with keys)
  eval "$(ssh-agent -s)" >/dev/null
  if [[ "$(uname)" == Darwin ]]; then
    ssh-add --apple-use-keychain ~/.ssh/id_ed25519 # the passphrase comes from the macOS keychain
  else
    ssh-add ~/.ssh/id_ed25519
  fi
fi

# Nightly `deno upgrade` (machine-local): once a day after 13:00, from the first prompt past that time.
if [[ -x "$HOME/.local/bin/deno-nightly-upgrade.sh" ]]; then
  _deno_nightly_upgrade() {
    local marker="$HOME/.local/state/deno-upgrade.last" today hour
    printf -v today '%(%Y-%m-%d)T' -1
    [[ -f "$marker" && "$(<"$marker")" == "$today" ]] && return
    printf -v hour '%(%H)T' -1
    ((10#$hour >= 13)) || return
    echo "$today" >"$marker"
    ("$HOME/.local/bin/deno-nightly-upgrade.sh" &>/dev/null &)
  }
  PROMPT_COMMAND="_deno_nightly_upgrade${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi

# Prompt.
if command -v starship >/dev/null; then
  export STARSHIP_CONFIG="$DOTFILES_BASH/starship.toml"
  eval "$(starship init bash)"
fi

# Machine-local extras that do not belong in git.
[[ -f "$HOME/.bashrc.local" ]] && . "$HOME/.bashrc.local"

[[ -n "${BLE_VERSION:-}" ]] && ble-attach
