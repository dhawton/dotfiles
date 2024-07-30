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
  command -v apt-get && sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch && sudo apt-get update -y && sudo apt-get install -y git python3-pip build-essential libncurses5-dev libncursesw5-dev libssl-dev autoconf automake curl zsh fastfetch unzip
  command -v dnf && sudo dnf update -y && sudo dnf install -y git pip ncurses-devel ncurses openssl-devel automake autoconf g++ curl zsh && sudo dnf -y groupinstall "Development Tools"
  command -v zypper && sudo zypper dup && sudo zypper in -y git python311-pip ncurses-devel ncurses openssl-devel automake autoconf gcc gcc-c++ curl zsh fastfetch && sudo zypper install --type pattern devel_basis

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
    if command -v apt-get >/dev/null 2>&1; then
      type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
        sudo apt update &&
        sudo apt install gh -y
    elif command -v dnf >/dev/null 2>&1; then
      sudo dnf install 'dnf-command(config-manager)'
      sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
      sudo dnf install -y gh
    elif command -v zypper >/dev/null 2>&1; then
      sudo zypper addrepo https://cli.github.com/packages/rpm/gh-cli.repo || true
      sudo zypper refresh
      sudo zypper install -y gh
    else
      echo "Unsupported system."
      exit 1
    fi

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
  ~/.fzf/install --all
fi #Shell Only

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Check if ~/.zshrc exists, could be symlink, if not symlink to shell/.zshrc
ln -s "$BASEDIR"/shell/.zshrc ~/.zshrc --force

# Same with .oh-my-zsh/custom
#if [[ -d ~/.oh-my-zsh/custom ]]; then
#  rm -rf ~/.oh-my-zsh/custom
#fi
ln -s "$BASEDIR"/shell/.oh-my-zsh/custom ~/.oh-my-zsh-custom --force

# Lastly ~/.p10k.zsh
ln -s "$BASEDIR"/shell/.p10k.zsh ~/.p10k.zsh --force

# Last, but not least, start the new shell
zsh
