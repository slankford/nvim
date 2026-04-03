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
	lazy = false,
	event = "InsertEnter",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		{
			"JoosepAlviste/nvim-ts-context-commentstring",
			opts = {
				enable_autocmd = false,
			},
		},
	},
	config = function()
		local ok, integration = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
		local ts_pre_hook = ok and integration.create_pre_hook() or nil
		local pre_hook = function(ctx)
			local ft = vim.bo.filetype
			local needs_context = ft == "javascript"
				or ft == "typescript"
				or ft == "javascriptreact"
				or ft == "typescriptreact"
				or ft == "svelte"
				or ft == "vue"
			if not needs_context or not ts_pre_hook then
				return nil
			end
			local hook_ok, value = pcall(ts_pre_hook, ctx)
			if not hook_ok then
				return nil
			end
			return value
		end
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
			pre_hook = pre_hook,
			post_hook = nil,
		})
	end,
}
