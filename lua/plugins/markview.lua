-- ================================================================================================
-- TITLE : markview.nvim
-- ABOUT : Markdown previewer
-- LINKS :
--   > github : https://github.com/OXY2DEV/markview.nvim
-- ================================================================================================
--
return {
	"OXY2DEV/markview.nvim",
	lazy = false,

	-- Completion for `blink.cmp`
	-- dependencies = { "saghen/blink.cmp" },
	config = function()
		-- Keymaps
		vim.keymap.set("n", "<leader>tm", ":Markview splitToggle<CR>", { desc = "Toggle Markview split view" })
		vim.keymap.set("n", "<leader>tM", ":Markview toggle<CR>", { desc = "Toggle Markview in current buffer" })
	end,
}
