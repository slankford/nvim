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

		-- Over SSH, TERM_PROGRAM isn't forwarded so smart-splits can't detect WezTerm (and the
		-- remote has no `wezterm cli`). Talk to the local WezTerm via OSC 1337 user vars instead.
		local remote_wezterm = vim.env.SSH_TTY ~= nil and (vim.env.TERM_PROGRAM or ""):lower() ~= "wezterm"

		local function set_wezterm_var(name, value)
			local osc = string.format("\027]1337;SetUserVar=%s=%s\007", name, vim.base64.encode(value))
			vim.fn["smart_splits#write_wezterm_var"](osc)
		end

		local nav_count = 0

		ss.setup({
			ignored_buftypes = { "quickfix", "prompt" },
			ignored_filetypes = { "NvimTree", "nvim-tree" },
			-- Only used when the multiplexer integration is unavailable (i.e. over SSH)
			at_edge = remote_wezterm and function(ctx)
				-- Counter makes every press a new value so WezTerm's user-var-changed always fires
				nav_count = nav_count + 1
				set_wezterm_var("NVIM_NAV", ctx.direction .. ":" .. nav_count)
			end or nil,
		})

		if remote_wezterm then
			-- Lets WezTerm's is_vim() see nvim behind the ssh process and forward Ctrl+Cmd+hjkl
			local group = vim.api.nvim_create_augroup("SmartSplitsRemoteWezterm", {})
			vim.api.nvim_create_autocmd({ "VimEnter", "VimResume" }, {
				group = group,
				callback = function()
					set_wezterm_var("IS_NVIM", "true")
				end,
			})
			vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, {
				group = group,
				callback = function()
					set_wezterm_var("IS_NVIM", "false")
				end,
			})
		end

		-- Move between splits; falls back to WezTerm panes when at the edge.
		-- <C-hjkl>: WezTerm forwards Ctrl+Cmd (mac) / Ctrl+Alt (windows) + hjkl as plain Ctrl
		-- <C-M-hjkl>: Ctrl+Alt + hjkl pressed directly on mac (WezTerm doesn't bind it)
		for _, lhs in ipairs({ "<C-%s>", "<C-M-%s>" }) do
			vim.keymap.set("n", lhs:format("h"), ss.move_cursor_left, { silent = true, desc = "Move left (split/pane)" })
			vim.keymap.set("n", lhs:format("j"), ss.move_cursor_down, { silent = true, desc = "Move down (split/pane)" })
			vim.keymap.set("n", lhs:format("k"), ss.move_cursor_up, { silent = true, desc = "Move up (split/pane)" })
			vim.keymap.set("n", lhs:format("l"), ss.move_cursor_right, { silent = true, desc = "Move right (split/pane)" })
		end

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
