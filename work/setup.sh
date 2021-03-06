#!/bin/bash

pwd=`pwd`
istiover=1.13.4

function lnfile() {
  file=$1

  if [[ -f "$HOME/$file" ]]; then
    echo "Warning: File $HOME/$file exists, will remove"
    rm -rf $HOME/$file
  fi

  ln -s $pwd/$file $HOME/$file
}

if [[ ! -d ".local" ]]; then
  echo "Run from the same directory as the files"
  exit 1
fi

if [[ -d "$HOME/.local" ]]; then
  echo "Warning: Directory $HOME/.local already exists, will try copying instead"
  cp -R .local/* $HOME/.local/
else
  ln -s $HOME/.local .local
fi

mkdir $HOME/.config &>/dev/null

files=(.personalrc .vimrc .config/starship.toml)
for file in "${files[@]}"; do
  echo "Installing $file"
  lnfile $file
done

echo "Installing istio to $HOME/work"
if [[ ! -d "$HOME/work" ]]; then
  mkdir "$HOME/work"
fi
if [[ ! -z $ISTIO_VERSION ]]; then
  istiover=$ISTIO_VERSION
fi

curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$istiover sh -

echo "Setting up symlink used for path"

ln -s "$HOME/work/istio-$istiover" "$HOME/istio"
mkdir $HOME/dev
ln -s "$pwd/cluster-tools" "$HOME/dev/cluster-tools"

echo "Installing meshctl"

curl -sL https://run.solo.io/meshctl/install | sh

echo "Done"
