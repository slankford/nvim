#!/usr/bin/env bash
set -eo pipefail

read -r -p "Configure Starship prompt and theme? [y/N]: " starship_answer
case "$starship_answer" in
[yY] | [yY][eE][sS]) ENABLE_STARSHIP=true ;;
*) ENABLE_STARSHIP=false ;;
esac

if [ ! -d "$HOME/.fzf" ]; then
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
fi
~/.fzf/install --all --no-update-rc

# Install important deps for Nvim
sudo apt update
sudo apt install -y ripgrep build-essential clang zsh zsh-autosuggestions zsh-syntax-highlighting zoxide nodejs npm

LS_TOOL=""
if apt-cache show eza >/dev/null 2>&1; then
	sudo apt install -y eza
	LS_TOOL="eza"
	echo "Installed eza for file listing aliases."
elif apt-cache show exa >/dev/null 2>&1; then
	sudo apt install -y exa
	LS_TOOL="exa"
	echo "Installed exa for file listing aliases (eza unavailable)."
else
	echo "Skipping eza/exa install: package not found in apt repos."
fi

## nvm for node/npm:
if curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash; then
	export NVM_DIR="$HOME/.nvm"
	if [ -s "$NVM_DIR/nvm.sh" ]; then
		. "$NVM_DIR/nvm.sh"
		if command -v nvm >/dev/null 2>&1; then
			nvm install --lts
			nvm use --lts
			nvm alias default 'lts/*'
			echo "nvm installed and LTS node activated."
		else
			echo "nvm install script ran, but nvm is unavailable; using apt node/npm."
		fi
	else
		echo "nvm init script not found; using apt node/npm."
	fi
else
	echo "nvm install failed; using apt node/npm."
fi

if ! command -v npm >/dev/null 2>&1; then
	echo "npm was not found after setup; install aborted."
	exit 1
fi

## tree-sitter-cli
npm install -g tree-sitter-cli || true
if ! tree-sitter --version 2>/dev/null; then
	echo "npm tree-sitter-cli unavailable; trying cargo fallback..."
	sudo apt install -y cargo
	npm uninstall -g tree-sitter-cli || true
	if cargo install tree-sitter-cli --version 0.24.7 --locked; then
		echo "Installed tree-sitter-cli via cargo (pinned, locked)."
	else
		echo "Cargo install failed, updating Rust toolchain with rustup..."
		if ! command -v rustup >/dev/null 2>&1; then
			curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
		fi
		export PATH="$HOME/.cargo/bin:$PATH"
		rustup toolchain install stable
		rustup default stable
		cargo install tree-sitter-cli --version 0.24.7 --locked
		echo "Installed tree-sitter-cli via cargo after rustup update."
	fi
	"$HOME/.cargo/bin/tree-sitter" --version
fi

# Install nvim and nvim config
sudo snap install nvim --classic || true
mkdir -p ~/.config
if [ ! -d "$HOME/.config/nvim" ]; then
	git clone https://github.com/slankford/nvim.git ~/.config/nvim
fi

if [ "$ENABLE_STARSHIP" = true ]; then
	# Starship config (overwrite every run for consistency)
	cat >"$HOME/.config/starship.toml" <<'EOF'
format = "$username$hostname $directory$fill$line_break$character"
right_format = "$time"

[fill]
symbol = "."

[time]
disabled = false
time_format = "%H:%M:%S"
format = "[$time]($style)"
style = "dimmed"

 [username]
show_always = true
format = "[$user]($style)"
style_user = "bold green"
style_root = "bold red"

[hostname]
ssh_only = false
format = "[@$hostname]($style)"
style = "yellow"
EOF

	# Starship prompt
	curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# zsh shell setup
touch "$HOME/.zshrc"
grep -q 'export PATH="$HOME/.fzf/bin:$PATH"' "$HOME/.zshrc" || echo 'export PATH="$HOME/.fzf/bin:$PATH"' >>"$HOME/.zshrc"
grep -q '\$HOME/.fzf/shell/completion.zsh' "$HOME/.zshrc" || echo '[ -f "$HOME/.fzf/shell/completion.zsh" ] && source "$HOME/.fzf/shell/completion.zsh"' >>"$HOME/.zshrc"
grep -q '\$HOME/.fzf/shell/key-bindings.zsh' "$HOME/.zshrc" || echo '[ -f "$HOME/.fzf/shell/key-bindings.zsh" ] && source "$HOME/.fzf/shell/key-bindings.zsh"' >>"$HOME/.zshrc"
grep -q 'zsh-autosuggestions.zsh' "$HOME/.zshrc" || echo 'source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >>"$HOME/.zshrc"
grep -q 'zsh-syntax-highlighting.zsh' "$HOME/.zshrc" || echo 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >>"$HOME/.zshrc"
if [ "$ENABLE_STARSHIP" = true ]; then
	grep -q 'starship init zsh' "$HOME/.zshrc" || echo 'eval "$(starship init zsh)"' >>"$HOME/.zshrc"
fi
grep -q 'zoxide init zsh' "$HOME/.zshrc" || echo 'eval "$(zoxide init zsh)"' >>"$HOME/.zshrc"
if ls --color=auto >/dev/null 2>&1; then
	grep -q "alias ls='ls --color=auto'" "$HOME/.zshrc" || echo "alias ls='ls --color=auto'" >>"$HOME/.zshrc"
fi

if [ "$LS_TOOL" = "eza" ] || command -v eza >/dev/null 2>&1; then
	grep -q "alias la='eza -la --icons=auto'" "$HOME/.zshrc" || echo "alias la='eza -la --icons=auto'" >>"$HOME/.zshrc"
elif [ "$LS_TOOL" = "exa" ] || command -v exa >/dev/null 2>&1; then
	grep -q "alias la='exa -la --icons'" "$HOME/.zshrc" || echo "alias la='exa -la --icons'" >>"$HOME/.zshrc"
else
	echo "No eza/exa found; skipping 'la' alias setup."
fi
grep -q '^HISTFILE=\$HOME/.zsh_history' "$HOME/.zshrc" || echo 'HISTFILE=$HOME/.zsh_history' >>"$HOME/.zshrc"
grep -q '^HISTSIZE=10000' "$HOME/.zshrc" || echo 'HISTSIZE=10000' >>"$HOME/.zshrc"
grep -q '^SAVEHIST=10000' "$HOME/.zshrc" || echo 'SAVEHIST=10000' >>"$HOME/.zshrc"
grep -q 'setopt append_history' "$HOME/.zshrc" || echo 'setopt append_history' >>"$HOME/.zshrc"
grep -q 'setopt share_history' "$HOME/.zshrc" || echo 'setopt share_history' >>"$HOME/.zshrc"
grep -q 'setopt hist_ignore_dups' "$HOME/.zshrc" || echo 'setopt hist_ignore_dups' >>"$HOME/.zshrc"
grep -q 'setopt hist_expire_dups_first' "$HOME/.zshrc" || echo 'setopt hist_expire_dups_first' >>"$HOME/.zshrc"

# set default shell to zsh when possible
if command -v zsh >/dev/null 2>&1; then
	CURRENT_SHELL="${SHELL:-}"
	ZSH_PATH="$(command -v zsh)"
	if [ -f "$HOME/.bash_history" ] && [ ! -f "$HOME/.zsh_history_imported_from_bash" ]; then
		touch "$HOME/.zsh_history"
		cat "$HOME/.bash_history" >>"$HOME/.zsh_history"
		touch "$HOME/.zsh_history_imported_from_bash"
	fi
	if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
		if chsh -s "$ZSH_PATH" "$USER"; then
			echo "Default shell changed to zsh. Log out/in to apply."
		else
			echo "Could not change default shell automatically. Run: chsh -s $ZSH_PATH"
		fi
	fi
fi
