-- ================================================================================================
-- TITLE : telescope.nvim
-- ABOUT : Fuzzy finder and picker keymaps.
-- LINKS :
--   > github : https://github.com/nvim-telescope/telescope.nvim
-- ================================================================================================

return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
	},
	config = function()
		-- Keymaps
		vim.keymap.set("n", "<leader>u", "<cmd>Telescope lsp_references<CR>", { noremap = true, silent = true })

		local tb = function() return require("telescope.builtin") end
		vim.keymap.set("n", "<leader>pf", function() tb().find_files() end, { desc = "All files search" })
		vim.keymap.set("n", "<leader>ff", function() tb().find_files() end, { desc = "All files search" })
		vim.keymap.set("n", "<C-p>", function() tb().git_files() end, { desc = "Git files search" })
		vim.keymap.set("n", "<leader>pG", function() tb().git_files() end, { desc = "Git files search" })
		vim.keymap.set("n", "<leader>pg", function() tb().git_status() end, { desc = "Git status" })
		vim.keymap.set("n", "<leader>pb", function() tb().buffers() end, { desc = "Buffer search" })
		vim.keymap.set("n", "<leader>fb", function() tb().buffers() end, { desc = "Buffer search" })
		vim.keymap.set("n", "<leader>ps", function() tb().live_grep() end, { desc = "Live grep" })
		vim.keymap.set("n", "<leader>fg", function() tb().live_grep() end, { desc = "Live grep" })
		vim.keymap.set("n", "<leader>fh", function() tb().help_tags() end, { desc = "Help tags search" })
		vim.keymap.set("n", "<leader>ph", function() tb().help_tags() end, { desc = "Help tags search" })
		vim.keymap.set("n", "<leader>px", function() tb().diagnostics() end, { desc = "Diagnostics search" })
		vim.keymap.set("n", "<leader>fx", function() tb().diagnostics() end, { desc = "Diagnostics search" })
		vim.keymap.set("n", "<leader>fs", function() tb().lsp_document_symbols() end, { desc = "Document symbol search" })
		vim.keymap.set("n", "<leader>fS", function() tb().lsp_workspace_symbols() end, { desc = "Workspace symbol search" })
	end,
}
