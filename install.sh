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
# Install dependencies
command -v apt-get && sudo apt-get update -y && sudo apt-get install -y git python3-pip build-essential libncurses5-dev libncursesw5-dev libssl-dev autoconf automake
command -v dnf && sudo dnf update -y && sudo dnf install -y git pip ncurses-devel ncurses openssl-devel automake autoconf g++ && sudo dnf -y groupinstall "Development Tools"

# Install asdf
if [[ -d "$HOME"/.asdf ]]; then
  rm -rf "$HOME"/.asdf
fi

git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
source "$HOME"/.asdf/asdf.sh

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
  curl https://sdk.cloud.google.com > install-gcp.sh
  bash install-gcp.sh --disable-prompts || true
  rm install-gcp.sh
fi

# Install doctl
brew install doctl

# Erlang+elixir
command -v apt-get || sudo apt-get update -y && sudo apt-get install -y unzip
command -v dnf || sudo dnf update -y && sudo dnf install -y unzip

asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git

asdf install erlang latest
asdf install elixir latest

asdf global erlang latest
asdf global elixir latest

# Install some other pre-reqs
brew install jq

# github cli
if command -v apt-get >/dev/null 2>&1; then
  type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install 'dnf-command(config-manager)'
  sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
  sudo dnf install -y gh
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

# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# Install lazygit
brew install lazygit

# Install node
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs latest
asdf global nodejs latest

# Install other tools
brew install kubectl
brew install fzf
brew install kubectx
go install github.com/mikefarah/yq/v4@latest
cargo install bottom
cargo install bat
cargo install ripgrep

if command -v apt >> /dev/null; then
  sudo apt install -y screen
elif command -v dnf >> /dev/null; then
  sudo dnf install -y screen
fi

# Install protobuf
brew install protobuf

# install fzf
if [ ! -d $HOME/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
fi
~/.fzf/install --all

# Check if ~/.zshrc exists, could be symlink, if not symlink to shell/.zshrc
ln -s "$BASEDIR"/shell/.zshrc ~/.zshrc --force

# Same with .oh-my-zsh/custom
if [[ -d ~/.oh-my-zsh/custom ]]; then
  rm -rf ~/.oh-my-zsh/custom
fi
ln -s "$BASEDIR"/shell/.oh-my-zsh/custom ~/.oh-my-zsh/custom --force

# Lastly ~/.p10k.zsh
ln -s "$BASEDIR"/shell/.p10k.zsh ~/.p10k.zsh --force
