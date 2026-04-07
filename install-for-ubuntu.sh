#!/bin/bash

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
sudo apt-get update
sudo apt-get install -y build-essential clang curl ca-certificates

curl https://sh.rustup.rs -sSf | sh -s -- -y
. "$HOME/.cargo/env"
cargo install tree-sitter-cli --locked
# optional persistence (for future shells)
grep -q 'cargo/bin' "$HOME/.bashrc" || echo 'export PATH="$HOME/.cargo/bin:$PATH"' >>"$HOME/.bashrc"
# verify now (no shell reload needed)
"$HOME/.cargo/bin/tree-sitter" --version

# Install nvim and nvim config
sudo snap install nvim --classic
mkdir ~/.config
git clone https://github.com/slankford/nvim.git ~/.config/nvim
