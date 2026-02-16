# Neovim (WSL) — Requirements

## Neovim version
This config includes a compatibility shim for **Neovim 0.10** (e.g. from `apt` on WSL). For the best experience, **Neovim 0.11+** is recommended. Without the shim, `nvim-notify` would error on 0.10 when nvim-tree or LSP triggers a notification (`vim.version.ge` is nil).

To upgrade on WSL (optional):
```bash
# Option: use appimage or build from source for 0.11+
# Or wait for your distro to ship 0.11+
```

## System packages (apt)
Install these on WSL to cover Neovim and common CLI tools used by this config:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
  neovim git curl build-essential cmake pkg-config \
  python3 python3-pip python3-venv \
  nodejs npm \
  openjdk-17-jdk golang-go \
  ripgrep fd-find fzf universal-ctags \
  clangd clang-format

sudo ln -s "$(which fdfind)" /usr/local/bin/fd || true

python3 -m pip install --user pynvim
