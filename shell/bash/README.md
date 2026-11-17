# bash setup

Replaces zsh + oh-my-zsh + powerlevel10k. AI coding tools work best in bash.

- `starship.toml`: the prompt. It looks like the old p10k "lean" prompt (user@host, folder, git, error, time).
- `blerc`: [ble.sh](https://github.com/akinomyoga/ble.sh) settings: grey suggestions from history, short old prompts, shared history.
- `aliases.bash`, `functions.bash`: the oh-my-zsh git and kubectl aliases, and our own.
- `.bashrc`, `bash_profile`, `inputrc`: linked to `~/.bashrc`, `~/.bash_profile`, `~/.inputrc`.

## Install

```sh
git clone git@github.com:dhawton/dotfiles ~/dev/dotfiles
~/dev/dotfiles/shell/bash/install.sh          # try it: run `bash`
~/dev/dotfiles/shell/bash/install.sh --chsh   # make bash the login shell
```

On macOS, install Homebrew first. The script then also installs Homebrew's bash 5 (macOS's `/bin/bash` is 3.2,
too old for this setup), and `--chsh` adds it to `/etc/shells` (sudo) before it makes it the login shell. Put
machine-only lines (for example `BWS_ACCESS_TOKEN`, `KUBECONFIG`) in `~/.bashrc.local`.

The script is safe to run again. It keeps old files as `<file>.pre-dotfiles.<date>` and copies the zsh history
once. Put settings for one machine only in `~/.bashrc.local`.

## AI tools

`.bashrc` skips the prompt, ble.sh and fastfetch when `CLAUDECODE` is set or there is no terminal. AI tools still
get PATH, aliases and functions.

## Back to zsh

`chsh -s /usr/bin/zsh`. The zsh files are still in `shell/`.
