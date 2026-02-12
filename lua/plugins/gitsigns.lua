-- ================================================================================================
-- TITLE : gitsigns
-- LINKS :
-- ABOUT : Git diffs in line
-- ================================================================================================

return {
	"lewis6991/gitsigns.nvim",
	config = function()
		local gs = require("gitsigns")

		gs.setup({
			current_line_blame = true,
		})

		-- GitSigns maps
		vim.keymap.set("n", "]c", gs.next_hunk, { desc = "GitSigns next hunk" })
		vim.keymap.set("n", "[c", gs.prev_hunk, { desc = "GitSigns prev hunk" })
		vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { desc = "GitSigns preview hunk" })
		vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { desc = "GitSigns reset hunk" })
		vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { desc = "GitSigns stage hunk" })
		vim.keymap.set("n", "<leader>gb", gs.blame_line, { desc = "GitSigns blame line" })
		vim.keymap.set("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle in line blame" })
		vim.keymap.set("n", "<leader>gd", gs.diffthis, { desc = "Diff against other buffer" })
		-- Toggle diff view for current buffer
		vim.keymap.set("n", "<leader>gd", function()
			if vim.bo.modified then
				require("gitsigns").diffthis("~")
			else
				vim.cmd("diffupdate")
			end
		end, { desc = "Diff against other buffer" })
	end,
}
