return {
	"mrjones2014/smart-splits.nvim",
	lazy = false,
	config = function()
		local ss = require("smart-splits")

		local function nvim_tree_state()
			for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
				local buf = vim.api.nvim_win_get_buf(win)
				if vim.bo[buf].filetype == "NvimTree" then
					return win, vim.api.nvim_win_get_width(win)
				end
			end
		end

		local function resize_without_touching_tree(resize_fn)
			return function()
				local tree_win, tree_width = nvim_tree_state()
				resize_fn()
				if tree_win and tree_width and vim.api.nvim_win_is_valid(tree_win) then
					local current_tree_width = vim.api.nvim_win_get_width(tree_win)
					if current_tree_width ~= tree_width then
						pcall(vim.api.nvim_win_set_width, tree_win, tree_width)
					end
				end
			end
		end

		ss.setup({
			ignored_buftypes = { "quickfix", "prompt" },
			ignored_filetypes = { "NvimTree", "nvim-tree" },
		})

		-- Move between splits; falls back to WezTerm panes when at the edge
		vim.keymap.set("n", "<C-h>", ss.move_cursor_left, { silent = true, desc = "Move left (split/pane)" })
		vim.keymap.set("n", "<C-j>", ss.move_cursor_down, { silent = true, desc = "Move down (split/pane)" })
		vim.keymap.set("n", "<C-k>", ss.move_cursor_up, { silent = true, desc = "Move up (split/pane)" })
		vim.keymap.set("n", "<C-l>", ss.move_cursor_right, { silent = true, desc = "Move right (split/pane)" })

		-- Resize splits with Shift+Arrow keys
		vim.keymap.set({ "n", "t" }, "<S-Left>", resize_without_touching_tree(ss.resize_left), { silent = true, desc = "Resize left" })
		vim.keymap.set({ "n", "t" }, "<S-Down>", ss.resize_down, { silent = true, desc = "Resize down" })
		vim.keymap.set({ "n", "t" }, "<S-Up>", ss.resize_up, { silent = true, desc = "Resize up" })
		vim.keymap.set({ "n", "t" }, "<S-Right>", resize_without_touching_tree(ss.resize_right), { silent = true, desc = "Resize right" })

		-- -- Resize from terminal buffers (e.g. opencode terminal pane)
		-- vim.keymap.set("t", "<S-Left>", resize_without_touching_tree(ss.resize_left),  { silent = true, desc = "Resize left" })
		-- vim.keymap.set("t", "<S-Down>", resize_without_touching_tree("down"),   { silent = true, desc = "Resize down" })
		-- vim.keymap.set("t", "<S-Up>", resize_without_touching_tree("up"),       { silent = true, desc = "Resize up" })
		-- vim.keymap.set("t", "<S-Right>", resize_without_touching_tree(ss.resize_right), { silent = true, desc = "Resize right" })
	end,
}
