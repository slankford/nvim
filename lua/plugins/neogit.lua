-- ================================================================================================
-- TITLE : neogit
-- LINKS : https://github.com/neogitorg/neogit
-- ABOUT : Many git operations in Neovim
-- ================================================================================================

-- return {
-- 	"lewis6991/gitsigns.nvim",
-- 	config = function()
-- 		local gs = require("gitsigns")
--
-- 		gs.setup({
-- 			current_line_blame = true,
-- 		})
--
-- 		-- GitSigns maps
-- 		vim.keymap.set("n", "]c", gs.next_hunk, { desc = "GitSigns next hunk" })
-- 		vim.keymap.set("n", "[c", gs.prev_hunk, { desc = "GitSigns prev hunk" })
-- 		vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { desc = "GitSigns preview hunk" })
-- 		vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { desc = "GitSigns reset hunk" })
-- 		vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { desc = "GitSigns stage hunk" })
-- 		vim.keymap.set("n", "<leader>gb", gs.blame_line, { desc = "GitSigns blame line" })
-- 		vim.keymap.set("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle in line blame" })
-- 		vim.keymap.set("n", "<leader>gD", gs.diffthis, { desc = "Diff against head version of file" })
-- 		-- Toggle diff view for current buffer
-- 		vim.keymap.set("n", "<leader>gd", function()
-- 			if vim.bo.modified then
-- 				require("gitsigns").diffthis("~")
-- 			else
-- 				vim.cmd("diffupdate")
-- 			end
-- 		end, { desc = "Diff against other buffer (borken?)" })
-- 	end,
-- }

return {
	"NeogitOrg/neogit",
	lazy = true,
	dependencies = {
		"nvim-lua/plenary.nvim", -- required

		-- Only one of these is needed.
		"sindrets/diffview.nvim", -- optional
		-- "esmuellert/codediff.nvim", -- optional

		-- For a custom log pager
		"m00qek/baleia.nvim", -- optional

		-- Only one of these is needed.
		"nvim-telescope/telescope.nvim", -- optional
		-- "ibhagwan/fzf-lua", -- optional
		-- "nvim-mini/mini.pick", -- optional
		-- "folke/snacks.nvim", -- optional
	},
	cmd = "Neogit",
	keys = {
		{ "<leader>gg", "<cmd>Neogit<cr>", desc = "Show Neogit UI" },
		{ "<leader>gC", "<cmd>Neogit commit<cr>", desc = "Neogit commit" },
		{ "<leader>gP", "<cmd>Neogit push<cr>", desc = "Neogit push" },
		{ "<leader>gL", "<cmd>Neogit log<cr>", desc = "Neogit log" },
		{ "<leader>go", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
		{ "<leader>gO", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
		{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
	},
	config = function()
		local is_ssh = vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_TTY ~= nil

		require("neogit").setup({
			console_timeout = is_ssh and 2000 or 0,
			auto_show_console = not is_ssh,
			auto_show_console_on = "output",
			auto_close_console = true,
		})

		local console_cleanup_group = vim.api.nvim_create_augroup("NeogitConsoleCleanup", { clear = true })
		vim.api.nvim_create_autocmd({ "BufWinLeave", "BufHidden" }, {
			group = console_cleanup_group,
			callback = function(args)
				if not vim.api.nvim_buf_is_valid(args.buf) then
					return
				end

				if vim.api.nvim_buf_get_name(args.buf) ~= "NeogitConsole" then
					return
				end

				pcall(vim.api.nvim_buf_delete, args.buf, { force = true })
			end,
		})
	end,
}
