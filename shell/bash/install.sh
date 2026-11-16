#!/usr/bin/env bash
# Switch this machine's shell to the bash setup in this folder: starship prompt, ble.sh, bash-completion, fzf,
# the aliases and functions, and links for ~/.bashrc, ~/.bash_profile and ~/.inputrc.
#
# Usage: shell/bash/install.sh [--chsh] [--no-history]
#   --chsh        also make bash the login shell (asks for your password)
#   --no-history  do not copy the zsh history into ~/.bash_history
#
# Safe to run again: it skips what is already done. Old files get a backup named <file>.pre-dotfiles.<date>.
# Needs Linux, curl, tar and xz. Uses Homebrew when it is there; otherwise it puts starship in ~/.local/bin.

set -euo pipefail

HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
DO_CHSH=0
DO_HISTORY=1
for arg in "$@"; do
  case "$arg" in
    --chsh) DO_CHSH=1 ;;
    --no-history) DO_HISTORY=0 ;;
    -h | --help) sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$*" >&2; }

if [[ "$(uname)" != Linux ]]; then
  echo "Only Linux is supported." >&2
  exit 1
fi

# --- tools -------------------------------------------------------------------------------------------------------

for b in /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
  [[ -x "$b" ]] && eval "$("$b" shellenv)" && break
done

have() { # have <formula>: true when the tool is already there
  case "$1" in
    bash-completion@2) [[ -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]] ;;
    *) command -v "$1" >/dev/null ;;
  esac
}

if command -v brew >/dev/null; then
  for f in starship bash-completion@2 fzf; do
    if have "$f"; then
      say "$f is already installed"
    else
      say "Installing $f with Homebrew"
      brew install "$f"
    fi
  done
else
  warn "No Homebrew. Install bash-completion and fzf with your package manager."
  if ! command -v starship >/dev/null; then
    say "Installing starship into ~/.local/bin"
    mkdir -p "$HOME/.local/bin"
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin"
  fi
fi

# ble.sh: the nightly release is a ready-made build, so no make or gawk is needed.
if [[ -f "$HOME/.local/share/blesh/ble.sh" ]]; then
  say "ble.sh is already installed (update it with: ble-update)"
else
  say "Installing ble.sh into ~/.local/share/blesh"
  tmp="$(mktemp -d)"
  curl -fsSL https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz | tar -xJf - -C "$tmp"
  bash "$tmp"/ble-nightly*/ble.sh --install "$HOME/.local/share"
  rm -rf "$tmp"
fi

# --- links -------------------------------------------------------------------------------------------------------

link() { # link <file in this folder> <target in $HOME>
  local src="$HERE/$1" dst="$2"
  if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
    say "$dst already links to $src"
    return
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    mv "$dst" "$dst.pre-dotfiles.$STAMP"
    say "Old $dst moved to $dst.pre-dotfiles.$STAMP"
  fi
  ln -s "$src" "$dst"
  say "Linked $dst -> $src"
}

link .bashrc "$HOME/.bashrc"
link bash_profile "$HOME/.bash_profile"
link inputrc "$HOME/.inputrc"

# --- history -----------------------------------------------------------------------------------------------------

# zsh writes ": <time>:0;<command>"; bash with HISTTIMEFORMAT reads "#<time>" and then the command.
marker="$HOME/.local/state/dotfiles/zsh-history-imported"
if [[ $DO_HISTORY == 1 && ! -f "$marker" ]]; then
  for zh in "$HOME/.histfile" "$HOME/.zsh_history"; do
    [[ -s "$zh" ]] || continue
    say "Copying zsh history from $zh into ~/.bash_history"
    [[ -f "$HOME/.bash_history" ]] && cp "$HOME/.bash_history" "$HOME/.bash_history.pre-dotfiles.$STAMP"
    LC_ALL=C sed -E 's/^: ([0-9]+):[0-9]+;/#\1\n/' "$zh" >>"$HOME/.bash_history"
  done
  mkdir -p "$(dirname "$marker")"
  date >"$marker"
fi

# --- login shell -------------------------------------------------------------------------------------------------

bash_path="$(command -v bash)"
current="$(getent passwd "$USER" | cut -d: -f7)"
if [[ "$current" == */bash ]]; then
  say "bash is already the login shell"
elif [[ $DO_CHSH == 1 ]]; then
  if ! grep -qx "$bash_path" /etc/shells; then
    bash_path=/bin/bash
  fi
  say "Making $bash_path the login shell (asks for your password)"
  chsh -s "$bash_path"
else
  say "The login shell is still $current. Try bash first: run 'bash'."
  say "To switch for good: chsh -s $bash_path   (or run this script again with --chsh)"
fi

say "Done. Open a new terminal to see it."
