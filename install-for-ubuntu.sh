#!/usr/bin/env bash
set -eo pipefail

# ---------------------------------------------------------------------------
# Component flags
# ---------------------------------------------------------------------------
INSTALL_FZF=false
INSTALL_ZSH=false
INSTALL_ZOXIDE=false
INSTALL_EZA=false
INSTALL_NVM=false
INSTALL_TREE_SITTER=false
INSTALL_NVIM=false
INSTALL_STARSHIP=false

LS_TOOL=""

# ---------------------------------------------------------------------------
# Interactive menu
# ---------------------------------------------------------------------------
select_components() {
	echo ""
	echo "Select components to install (space-separated numbers, or 'all'):"
	echo "  1) fzf               – fuzzy finder"
	echo "  2) zsh + plugins     – zsh, autosuggestions, syntax-highlighting, default shell"
	echo "  3) zoxide            – smart directory navigation"
	echo "  4) eza               – modern ls replacement (eza/exa)"
	echo "  5) nvm               – Node Version Manager + LTS node"
	echo "  6) tree-sitter-cli   – tree-sitter CLI (requires npm/cargo)"
	echo "  7) nvim              – Neovim + config (includes ripgrep, build-essential, clang)"
	echo "  8) starship          – shell prompt + theme"
	echo ""
	read -r -p "> " selection

	if [ "$selection" = "all" ]; then
		INSTALL_FZF=true
		INSTALL_ZSH=true
		INSTALL_ZOXIDE=true
		INSTALL_EZA=true
		INSTALL_NVM=true
		INSTALL_TREE_SITTER=true
		INSTALL_NVIM=true
		INSTALL_STARSHIP=true
		return
	fi

	for token in $selection; do
		case "$token" in
		1) INSTALL_FZF=true ;;
		2) INSTALL_ZSH=true ;;
		3) INSTALL_ZOXIDE=true ;;
		4) INSTALL_EZA=true ;;
		5) INSTALL_NVM=true ;;
		6) INSTALL_TREE_SITTER=true ;;
		7) INSTALL_NVIM=true ;;
		8) INSTALL_STARSHIP=true ;;
		*) echo "Unknown option: $token (ignored)" ;;
		esac
	done
}

# ---------------------------------------------------------------------------
# apt update – only once, only if needed
# ---------------------------------------------------------------------------
apt_update_if_needed() {
	if [ "$INSTALL_ZSH" = true ] || [ "$INSTALL_ZOXIDE" = true ] ||
		[ "$INSTALL_EZA" = true ] || [ "$INSTALL_NVIM" = true ]; then
		sudo apt-get update || true
	fi
}

# ---------------------------------------------------------------------------
# Installers
# ---------------------------------------------------------------------------
install_fzf() {
	if [ ! -d "$HOME/.fzf" ]; then
		git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	fi
	~/.fzf/install --all --no-update-rc
}

install_zsh() {
	sudo apt-get install -y zsh zsh-autosuggestions zsh-syntax-highlighting
}

install_zoxide() {
	sudo apt-get install -y zoxide
}

install_eza() {
	if apt-cache show eza >/dev/null 2>&1; then
		sudo apt-get install -y eza
		LS_TOOL="eza"
		echo "Installed eza for file listing aliases."
	elif apt-cache show exa >/dev/null 2>&1; then
		sudo apt-get install -y exa
		LS_TOOL="exa"
		echo "Installed exa for file listing aliases (eza unavailable)."
	else
		echo "Skipping eza/exa install: package not found in apt repos."
	fi
}

install_nvm() {
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
}

install_tree_sitter() {
	if ! command -v npm >/dev/null 2>&1; then
		echo "npm not found; installing nodejs/npm via apt before tree-sitter-cli..."
		sudo apt-get install -y nodejs npm
	fi

	npm install -g tree-sitter-cli || true
	if ! tree-sitter --version 2>/dev/null; then
		echo "npm tree-sitter-cli unavailable; trying cargo fallback..."
		sudo apt-get install -y cargo
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
}

install_nvim() {
	sudo apt-get install -y ripgrep build-essential clang
	sudo snap install nvim --classic || true
	mkdir -p ~/.config
	if [ ! -d "$HOME/.config/nvim" ]; then
		git clone https://github.com/slankford/nvim.git ~/.config/nvim
	fi
}

install_starship() {
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
	curl -sS https://starship.rs/install.sh | sh -s -- -y
}

# ---------------------------------------------------------------------------
# .zshrc configuration
# ---------------------------------------------------------------------------
configure_zshrc() {
	touch "$HOME/.zshrc"

	if [ "$INSTALL_FZF" = true ]; then
		grep -q "export PATH='$HOME/.fzf/bin:$PATH'" "$HOME/.zshrc" ||
			echo "export PATH='$HOME/.fzf/bin:$PATH'" >>"$HOME/.zshrc"
		grep -q "\$HOME/.fzf/shell/completion.zsh" "$HOME/.zshrc" ||
			echo "[ -f '$HOME/.fzf/shell/completion.zsh' ] && source '$HOME/.fzf/shell/completion.zsh'" >>"$HOME/.zshrc"
		grep -q "\$HOME/.fzf/shell/key-bindings.zsh" "$HOME/.zshrc" ||
			echo "[ -f '$HOME/.fzf/shell/key-bindings.zsh' ] && source '$HOME/.fzf/shell/key-bindings.zsh'" >>"$HOME/.zshrc"
	fi

	if [ "$INSTALL_ZSH" = true ]; then
		grep -q 'zsh-autosuggestions.zsh' "$HOME/.zshrc" ||
			echo 'source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >>"$HOME/.zshrc"
		grep -q 'zsh-syntax-highlighting.zsh' "$HOME/.zshrc" ||
			echo 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >>"$HOME/.zshrc"
		grep -q "^HISTFILE=\$HOME/.zsh_history" "$HOME/.zshrc" || echo "HISTFILE=$HOME/.zsh_history" >>"$HOME/.zshrc"
		grep -q '^HISTSIZE=10000' "$HOME/.zshrc" || echo 'HISTSIZE=10000' >>"$HOME/.zshrc"
		grep -q '^SAVEHIST=10000' "$HOME/.zshrc" || echo 'SAVEHIST=10000' >>"$HOME/.zshrc"
		grep -q 'setopt append_history' "$HOME/.zshrc" || echo 'setopt append_history' >>"$HOME/.zshrc"
		grep -q 'setopt share_history' "$HOME/.zshrc" || echo 'setopt share_history' >>"$HOME/.zshrc"
		grep -q 'setopt hist_ignore_dups' "$HOME/.zshrc" || echo 'setopt hist_ignore_dups' >>"$HOME/.zshrc"
		grep -q 'setopt hist_expire_dups_first' "$HOME/.zshrc" || echo 'setopt hist_expire_dups_first' >>"$HOME/.zshrc"
	fi

	if [ "$INSTALL_STARSHIP" = true ]; then
		grep -q 'starship init zsh' "$HOME/.zshrc" ||
			echo "eval '$(starship init zsh)'" >>"$HOME/.zshrc"
	fi

	if [ "$INSTALL_ZOXIDE" = true ]; then
		grep -q 'zoxide init zsh' "$HOME/.zshrc" ||
			echo "eval '$(zoxide init zsh)'" >>"$HOME/.zshrc"
	fi

	if ls --color=auto >/dev/null 2>&1; then
		grep -q "alias ls='ls --color=auto'" "$HOME/.zshrc" ||
			echo "alias ls='ls --color=auto'" >>"$HOME/.zshrc"
	fi

	if [ "$INSTALL_EZA" = true ]; then
		if [ "$LS_TOOL" = "eza" ] || command -v eza >/dev/null 2>&1; then
			grep -q "alias la='eza -la --icons=auto'" "$HOME/.zshrc" ||
				echo "alias la='eza -la --icons=auto'" >>"$HOME/.zshrc"
		elif [ "$LS_TOOL" = "exa" ] || command -v exa >/dev/null 2>&1; then
			grep -q "alias la='exa -la --icons'" "$HOME/.zshrc" ||
				echo "alias la='exa -la --icons'" >>"$HOME/.zshrc"
		else
			echo "No eza/exa found; skipping 'la' alias setup."
		fi
	fi
}

# ---------------------------------------------------------------------------
# Change default shell to zsh
# ---------------------------------------------------------------------------
change_default_shell() {
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
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
select_components

apt_update_if_needed

[ "$INSTALL_FZF" = true ] && install_fzf
[ "$INSTALL_ZSH" = true ] && install_zsh
[ "$INSTALL_ZOXIDE" = true ] && install_zoxide
[ "$INSTALL_EZA" = true ] && install_eza
[ "$INSTALL_NVM" = true ] && install_nvm
[ "$INSTALL_TREE_SITTER" = true ] && install_tree_sitter
[ "$INSTALL_NVIM" = true ] && install_nvim
[ "$INSTALL_STARSHIP" = true ] && install_starship

configure_zshrc

[ "$INSTALL_ZSH" = true ] && change_default_shell
