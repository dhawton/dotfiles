#!/usr/bin/env bash

set -ex

if [[ "$(uname)" != "Linux" ]]; then
  echo "Unsupported system."
  exit 1
fi

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${BASEDIR}"
git submodule update --init --recursive

sudo echo "Ready to install"
if [[ -z "${SHELL_ONLY:-}" ]]; then
  # Install dependencies
  command -v apt-get && sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch && sudo apt-get update -y && sudo apt-get install -y git python3-pip build-essential libncurses5-dev libncursesw5-dev libssl-dev autoconf automake curl xz-utils fastfetch unzip
  command -v dnf && sudo dnf update -y && sudo dnf install -y git pip ncurses-devel ncurses openssl-devel automake autoconf g++ curl xz
  command -v zypper && sudo zypper dup && sudo zypper in -y git python311-pip ncurses-devel ncurses openssl-devel automake autoconf gcc gcc-c++ curl xz fastfetch && sudo zypper install --type pattern devel_basis

  if [[ -z "${SKIP_SOFTWARE:-}" ]]; then
    # Install homebrew
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" || true
    if which brew; then
      echo 'Updating homebrew'
      brew update
    else
      echo "Installing Homebrew"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    # Install AWS tools
    if ! which aws; then
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
      rm -rf awscliv2.zip aws
    fi

    # Install gcloud
    if ! which gcloud; then
      curl https://sdk.cloud.google.com >install-gcp.sh
      bash install-gcp.sh --disable-prompts || true
      rm install-gcp.sh
    fi

    # Install doctl
    brew install doctl

    # Install some other pre-reqs
    brew install jq

    # github cli
    brew install gh

    # Install go
    DEFAULT_VER=$(curl -s https://go.dev/dl/?mode=json | jq -r ".[0].version")
    VER=${1:-$DEFAULT_VER}

    OS=linux
    if [[ "$OSTYPE" == "darwin"* ]]; then
      OS=darwin
    fi

    ARCH=amd64
    if [[ "$(uname -m)" == "arm64"* ]]; then
      ARCH=arm64
    fi

    echo "==> Downloading $VER"
    if ! wget https://golang.org/dl/"${VER}.${OS}-${ARCH}".tar.gz -O /tmp/go.tar.gz; then
      echo "Had an issue getting the new go installer ($?)"
      exit 1
    fi

    if [[ -d /usr/local/go ]]; then
      echo "==> Removing older go install"
      sudo rm -rf /usr/local/go
    fi

    echo "==> Extracting go to /usr/local"
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    echo "==> Cleaning up /tmp"
    rm /tmp/go.tar.gz
    echo "==> Done, running go version"

    export PATH=$PATH:/usr/local/go/bin

    go version
  fi

  # Install rust
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"

  # Install node
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

  # Install other tools
  if [[ -z "${SKIP_SOFTWARE:-}" ]]; then
    # Install lazygit
    brew install lazygit
    brew install kubectl
    brew install fzf
    brew install kubectx
    brew install neovim
  fi
  go install github.com/mikefarah/yq/v4@latest

  if command -v apt >>/dev/null; then
    sudo apt install -y screen
  elif command -v dnf >>/dev/null; then
    sudo dnf install -y screen
  elif command -v zypper >>/dev/null; then
    sudo zypper install -y screen
  fi

  if [[ -z "${SKIP_SOFTWARE:-}" ]]; then
    # Install protobuf
    brew install protobuf
  fi

  # install fzf
  if [ ! -d $HOME/.fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  fi
  ~/.fzf/install --key-bindings --completion --no-update-rc # .bashrc lives in git; it loads ~/.fzf.bash
fi #Shell Only

# Shell: bash + starship + ble.sh (shell/bash/install.sh). The old zsh setup (shell/.zshrc, .p10k.zsh,
# .oh-my-zsh/custom) stays in the repo for now but is no longer installed.
"$BASEDIR"/shell/bash/install.sh

# neovim
if [[ ! -d "~/.config" ]]; then
  mkdir ~/.config || true
fi
ln -s "$BASEDIR"/nvim ~/.config/nvim

echo "Log back in or type \"bash\" to continue. To make bash the login shell: chsh -s /bin/bash"
