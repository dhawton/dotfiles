#!/bin/bash

pwd=`pwd`

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

files=(.personalrc .vimrc)
for file in "${files[@]}"; do
  echo "Installing $file"
  lnfile $file
done

echo "Done"
