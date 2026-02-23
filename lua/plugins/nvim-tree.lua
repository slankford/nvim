-- ================================================================================================
-- TITLE : nvim-tree
-- ABOUT : File explorer tree and focused-file navigation.
-- LINKS :
--   > github : https://github.com/nvim-tree/nvim-tree.lua
-- ================================================================================================

return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		update_focused_file = {
			enable = true,
			-- update_root = true, -- updates root of the tree to the file's directory
		},
	},
	config = function()
		-- Remove background color form NvimTree window
		vim.cmd([[hi NvimTreeNormal guibg=NONE ctermbg=NONE]])

		-- Keymaps
		vim.keymap.set("n", "<leader>m", "<Cmd>NvimTreeFindFile<CR>", { desc = "Focus on file explorer" })
		vim.keymap.set("n", "<leader>e", "<Cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
		require("nvim-tree").setup({
			filters = {
				dotfiles = false, -- Show hidden files (dotfiles)
				git_ignored = false, -- Show gitignored files
			},
			view = {
				-- width = 35,
				preserve_window_proportions = true,
				adaptive_size = false,
			},
		})
	end,
}
