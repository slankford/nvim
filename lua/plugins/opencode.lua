-- ================================================================================================
-- TITLE : nickjvandyke/opencode.nvim
-- LINKS :
--   > github : https://github.com/nickjvandyke/opencode.nvim
-- ABOUT : Opencode plugin for vroom vroom
-- ================================================================================================

return {
	"nickjvandyke/opencode.nvim",
	dependencies = {
		-- Recommended for `ask()` and `select()`.
		-- Required for `snacks` provider.
		---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
		{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
	},
	config = function()
		local opencode_port_a = 11434
		local opencode_port_b = 11435
		local active_port = opencode_port_a

		local function keybind_for_port(port)
			if port == opencode_port_a then
				return "<leader>o."
			end
			if port == opencode_port_b then
				return "<leader>o,"
			end
			return "(no mapped keybind)"
		end

		local function set_active_port(port)
			active_port = port
			require("opencode.config").opts.server.port = port

			local events = require("opencode.events")
			if events.connected_server and events.connected_server.port ~= port then
				events.disconnect()
			end

			vim.notify(("opencode -> port %d"):format(port), vim.log.levels.INFO, { title = "opencode" })
		end

		local function is_port_listening(port)
			if vim.fn.executable("lsof") == 0 then
				return false
			end

			local output = vim.fn.system({
				"lsof",
				"-nP",
				"-iTCP:" .. tostring(port),
				"-sTCP:LISTEN",
				"-t",
			})

			if vim.v.shell_error ~= 0 then
				return false
			end

			return output ~= nil and output:match("%S") ~= nil
		end

		local function run_cmd(argv)
			vim.fn.system(argv)
			return vim.v.shell_error == 0
		end

		local function wezterm_split_pane_opencode(port)
			if vim.fn.executable("wezterm") == 0 then
				vim.notify("`wezterm` is not in PATH", vim.log.levels.ERROR, { title = "opencode" })
				return false
			end

			local cwd = vim.fn.getcwd()
			return run_cmd({
				"wezterm",
				"cli",
				"split-pane",
				"--right",
				"--percent",
				"35",
				"--cwd",
				cwd,
				"--",
				"opencode",
				"--port",
				tostring(port),
			})
		end

		local function wezterm_spawn_opencode_tab(port)
			if vim.fn.executable("wezterm") == 0 then
				vim.notify("`wezterm` is not in PATH", vim.log.levels.ERROR, { title = "opencode" })
				return false
			end

			local cwd = vim.fn.getcwd()
			if
				run_cmd({
					"wezterm",
					"cli",
					"spawn",
					"--cwd",
					cwd,
					"--",
					"opencode",
					"--port",
					tostring(port),
				})
			then
				return true
			end

			return run_cmd({
				"wezterm",
				"start",
				"--cwd",
				cwd,
				"opencode",
				"--port",
				tostring(port),
			})
		end

		local function launch_opencode(port)
			if wezterm_split_pane_opencode(port) then
				return
			end

			vim.notify("Split-pane launch failed, falling back to new tab", vim.log.levels.WARN, { title = "opencode" })

			if not wezterm_spawn_opencode_tab(port) then
				vim.notify(
					("Failed to launch opencode on port %d"):format(port),
					vim.log.levels.ERROR,
					{ title = "opencode" }
				)
			end
		end

		local function start_and_switch(port)
			set_active_port(port)
			if is_port_listening(port) then
				vim.notify(
					("opencode already running on %d (%s)"):format(port, keybind_for_port(port)),
					vim.log.levels.INFO,
					{ title = "opencode" }
				)
				return
			end

			launch_opencode(port)
		end

		local function show_active_port()
			local ok, events = pcall(require, "opencode.events")
			local connected = ok and events.connected_server or nil
			local connected_port = connected and connected.port or nil
			local active_keybind = keybind_for_port(active_port)
			local message
			if connected_port then
				message = ("opencode active port: %d (%s) (connected: %d)"):format(
					active_port,
					active_keybind,
					connected_port
				)
			else
				message = ("opencode active port: %d (%s) (not connected yet)"):format(active_port, active_keybind)
			end
			vim.notify(message, vim.log.levels.INFO, { title = "opencode" })
		end

		---@type opencode.Opts
		vim.g.opencode_opts = {
			server = {
				port = active_port,
				start = false,
				stop = false,
				toggle = false,
			},
		}

		-- Required for `opts.events.reload`.
		vim.o.autoread = true

		-- Recommended/example keymaps.
		vim.keymap.set({ "n", "v" }, "<leader>oa", function()
			set_active_port(active_port)
			require("opencode").ask("@this: ", { submit = true })
		end, { desc = "Ask opencode…" })

		vim.keymap.set({ "n", "v" }, "<leader>ox", function()
			set_active_port(active_port)
			require("opencode").select()
		end, { desc = "Execute opencode action…" })

		vim.keymap.set("n", "<leader>o.", function()
			start_and_switch(opencode_port_a)
		end, { desc = "Start/switch opencode A" })

		vim.keymap.set("n", "<leader>o,", function()
			start_and_switch(opencode_port_b)
		end, { desc = "Start/switch opencode B" })

		vim.keymap.set("n", "<leader>oq", function()
			require("opencode.events").disconnect()
		end, { desc = "Disconnect opencode.nvim" })

		vim.keymap.set("n", "<leader>op", function()
			show_active_port()
		end, { desc = "Show active opencode port" })

		-- Window Navigation
		vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Terminal -> left window" })
		vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Terminal -> lower window" })
		vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Terminal -> upper window" })
		vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Terminal -> right window" })

		vim.keymap.set({ "n", "v" }, "go", function()
			return require("opencode").operator("@this ")
		end, { desc = "Add range to opencode", expr = true })

		vim.keymap.set("n", "goo", function()
			return require("opencode").operator("@this ") .. "_"
		end, { desc = "Add line to opencode", expr = true })

		vim.keymap.set("n", "<S-C-u>", function()
			require("opencode").command("session.half.page.up")
		end, { desc = "Scroll opencode up" })

		vim.keymap.set("n", "<S-C-d>", function()
			require("opencode").command("session.half.page.down")
		end, { desc = "Scroll opencode down" })

		-- You may want these if you use the opinionated `<C-a>` and `<C-x>` keymaps above — otherwise consider `<leader>o…` (and remove terminal mode from the `toggle` keymap).
		vim.keymap.set("n", "+", "<leader>o+", { desc = "Increment under cursor", noremap = true })
		vim.keymap.set("n", "-", "<leader>o-", { desc = "Decrement under cursor", noremap = true })

		-- Kill all sessions for a refresh
		-- vim.keymap.set("n", "<leader>oc", function()
		-- 	local opencode = require("opencode")
		--
		-- 	-- Close sessions
		-- 	for _, session in pairs(opencode.sessions or {}) do
		-- 		session:close()
		-- 	end
		--
		-- 	-- Delete leftover opencode buffers
		-- 	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		-- 		if vim.bo[buf].filetype == "opencode" then
		-- 			vim.api.nvim_buf_delete(buf, { force = true })
		-- 		end
		-- 	end
		--
		-- 	print("Opencode sessions cleared ✅")
		-- end, { desc = "Close all opencode sessions" })
		--
		-- -- Kill all servers
		-- vim.keymap.set("n", "<leader>os", function()
		-- 	local opencode = require("opencode")
		-- 	for _, server in pairs(opencode.servers or {}) do
		-- 		server:stop()
		-- 	end
		-- 	print("All opencode servers stopped ✅")
		-- end, { desc = "Stop all opencode servers" })
		--
		-- -- opencode full reset
		-- vim.keymap.set("n", "<leader>or", function()
		-- 	local opencode = require("opencode")
		--
		-- 	-- Stop all server processes
		-- 	for _, server in pairs(opencode.servers or {}) do
		-- 		pcall(function()
		-- 			server:stop()
		-- 		end)
		-- 	end
		--
		-- 	-- Clear internal state
		-- 	opencode.servers = {}
		-- 	opencode.session = nil
		-- 	opencode.sessions = {}
		--
		-- 	print("Opencode fully reset ✅")
		-- end, { desc = "Reset all opencode servers and sessions" })
	end,
}
