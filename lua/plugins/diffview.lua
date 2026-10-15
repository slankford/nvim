-- ================================================================================================
-- TITLE : diffview
-- LINKS : https://github.com/sindrets/diffview.nvim
-- ABOUT : Side-by-side git diffs (loaded via neogit)
-- ================================================================================================

return {
	"sindrets/diffview.nvim",
	lazy = true,
	cmd = { "DiffviewOpen", "DiffviewFileHistory" },
	config = function()
		require("diffview").setup({
			view = {
				default = { layout = "diff2_horizontal" },
				file_history = { layout = "diff2_horizontal" },
			},
		})

		-- WezTerm leaves stale cells in the scrollbound (non-focused) diff pane when it
		-- scrolls, garbling it. Force a full repaint whenever a diff window scrolls.
		local pending = false
		vim.api.nvim_create_autocmd("WinScrolled", {
			group = vim.api.nvim_create_augroup("DiffviewRedrawFix", { clear = true }),
			callback = function()
				if pending then
					return
				end
				for id in pairs(vim.v.event) do
					local win = tonumber(id)
					if win and vim.api.nvim_win_is_valid(win) and vim.wo[win].diff then
						pending = true
						vim.schedule(function()
							pending = false
							vim.cmd("redraw!")
						end)
						return
					end
				end
			end,
		})
	end,
}
