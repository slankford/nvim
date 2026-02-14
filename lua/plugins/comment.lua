-- ================================================================================================
-- TITLE: Comment.nvim
-- ABOUT: Plugin for smart commenting in Neovim. Provides easy-to-use keymaps for
--   commenting and uncommenting lines/blocks. Integrates with treesitter for context-aware
--   commenting in different file types (e.g., JSX, Vue).
-- LINKS: https://github.com/numToStr/Comment.nvim
--   https://github.com/JoosepAlviste/nvim-ts-context-commentstring
-- ================================================================================================

return {
	"numToStr/Comment.nvim",
	config = function()
		local prehook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()
		require("Comment").setup({
			padding = true,
			sticky = true,
			ignore = "^$",
			toggler = {
				line = "gcc",
				block = "gbc",
			},
			opleader = {
				line = "gc",
				block = "gb",
			},
			extra = {
				above = "gcO",
				below = "gco",
				eol = "gcA",
			},
			mappings = {
				basic = true,
				extra = true,
				extended = false,
			},
			pre_hook = prehook,
			post_hook = nil,
		})
	end,
	event = "InsertEnter",
	lazy = false,
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
}
