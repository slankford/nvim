-- ================================================================================================
-- TITLE : rcarriga/nvim-notify
-- ABOUT : Notification UI with history and manual dismiss.
-- LINKS :
--   > github : https://github.com/rcarriga/nvim-notify
-- ================================================================================================

return {
	"rcarriga/nvim-notify",
	opts = {
		timeout = 8000,
		max_height = 20,
		max_width = 90,
		render = "wrapped-compact",
	},
	config = function(_, opts)
		local notify = require("notify")
		notify.setup(opts)
		vim.notify = notify

		-- Keymaps
		vim.keymap.set("n", "<leader>nh", function()
			require("notify").history()
		end, { desc = "Notification History" })

		vim.keymap.set("n", "<leader>nD", function()
			require("notify").dismiss({ silent = true, pending = true })
		end, { desc = "Dismiss notifications" })
	end,
}
