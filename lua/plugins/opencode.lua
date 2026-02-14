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
		---@type opencode.Opts
		vim.g.opencode_opts = {
			-- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on the type or field.
		}

		-- Required for `opts.events.reload`.
		vim.o.autoread = true

		-- Recommended/example keymaps.
		vim.keymap.set({ "n", "x" }, "<leader>oa", function()
			require("opencode").ask("@this: ", { submit = true })
		end, { desc = "Ask opencode…" })

		vim.keymap.set({ "n", "x" }, "<leader>ox", function()
			require("opencode").select()
		end, { desc = "Execute opencode action…" })

		vim.keymap.set({ "n", "t" }, "<leader>o.", function()
			require("opencode").toggle()
		end, { desc = "Toggle opencode" })

		vim.keymap.set({ "n", "x" }, "go", function()
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
		vim.keymap.set("n", "<leader>oc", function()
			local opencode = require("opencode")

			-- Close sessions
			for _, session in pairs(opencode.sessions or {}) do
				session:close()
			end

			-- Delete leftover opencode buffers
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.bo[buf].filetype == "opencode" then
					vim.api.nvim_buf_delete(buf, { force = true })
				end
			end

			print("Opencode sessions cleared ✅")
		end, { desc = "Close all opencode sessions" })

		-- Kill all servers
		vim.keymap.set("n", "<leader>os", function()
			local opencode = require("opencode")
			for _, server in pairs(opencode.servers or {}) do
				server:stop()
			end
			print("All opencode servers stopped ✅")
		end, { desc = "Stop all opencode servers" })

		-- opencode full reset
		vim.keymap.set("n", "<leader>or", function()
			local opencode = require("opencode")

			-- Stop all server processes
			for _, server in pairs(opencode.servers or {}) do
				pcall(function()
					server:stop()
				end)
			end

			-- Clear internal state
			opencode.servers = {}
			opencode.session = nil
			opencode.sessions = {}

			print("Opencode fully reset ✅")
		end, { desc = "Reset all opencode servers and sessions" })
	end,
}
