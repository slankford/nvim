-- ================================================================================================
-- TITLE : which-key
-- ABOUT : WhichKey helps you remember your Neovim keymaps, by showing keybindings as you type.
-- LINKS :
--   > github : https://github.com/folke/which-key.nvim
-- ================================================================================================

return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		keys = { -- which-key specific functionality
			scroll_down = "<c-f>", -- Need rebinding because I customize c-u and c-d with zz in keymaps
			scroll_up = "<c-b>",
		},
	},
	keys = { -- passed into which-key's setup() interally to Lazy
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
