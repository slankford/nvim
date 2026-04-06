#!/bin/sh

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Install important deps for Nvim
sudo apt update
sudo apt install -y ripgrep

## nvm for node/npm:
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts
nvm alias default 'lts/*'

## c compiler for tree sitter
sudo apt install build-essential clang
npm install -g tree-sitter-cli
tree-sitter --version

# Install nvim and nvim config
sudo snap install nvim --classic
mkdir ~/.config
git clone https://github.com/slankford/nvim.git ~/.config/nvim
