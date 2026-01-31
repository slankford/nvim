-- Treesitter
return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile"},
	opts = {
		ensure_installed = {
			'help',
			'typescript',
			'javascript',
			'tsx',
			'jsx',
			'css',
			'html',
			'python',
			'bash',
			'lua',
			"markdown",
			"markdown_inline",
			"dockerfile",
			"json",
			"yaml",
			"vim",
			"vimdoc"
		},
		-- Autoinstall languages that are not installed
		auto_install = true,
		sync_install = false,

		-- Enable highlighting
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
			-- Disable highlighting for specific filetypes if needed
			-- disable = { "c", "lua" },
		},

		-- Enable indentation
		indent = {
			enable = true,
		},

		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<CR>",
				node_incremental = "<CR>",
				scope_incremental = "<CR>",
				node_decremental = "<S-TAB>",
			}
		}

	}
}
