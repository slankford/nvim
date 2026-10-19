-- ================================================================================================
-- TITLE : nvim-dap
-- ABOUT : Debug Adapter Protocol client, with a UI and adapters for Python and Angular (JS/TS).
-- LINKS :
--   > github                   : https://github.com/mfussenegger/nvim-dap
--   > nvim-dap-ui (dep)        : https://github.com/rcarriga/nvim-dap-ui
--   > nvim-dap-python (dep)    : https://github.com/mfussenegger/nvim-dap-python
--   > nvim-dap-virtual-text    : https://github.com/theHamsta/nvim-dap-virtual-text
--   > vscode-js-debug (adapter): https://github.com/microsoft/vscode-js-debug
-- ================================================================================================

local mason_path = vim.fn.stdpath("data") .. "/mason"

return {
	"mfussenegger/nvim-dap",
	dependencies = {
		{ "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
		"mfussenegger/nvim-dap-python",
		{ "theHamsta/nvim-dap-virtual-text", opts = {} }, -- Inline variable values while stepping
	},
	keys = {
		{ "<F5>", function() require("dap").continue() end, desc = "Debug: Start / Continue" },
		{ "<F6>", function() require("dap").step_over() end, desc = "Debug: Step over" },
		{ "<F7>", function() require("dap").step_into() end, desc = "Debug: Step into" },
		{ "<F8>", function() require("dap").step_out() end, desc = "Debug: Step out" },
		{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle breakpoint" },
		{
			"<leader>dB",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			desc = "Debug: Conditional breakpoint",
		},
		{ "<leader>dc", function() require("dap").continue() end, desc = "Debug: Start / Continue" },
		{ "<leader>dl", function() require("dap").run_last() end, desc = "Debug: Run last" },
		{ "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Debug: Run to cursor" },
		{ "<leader>dt", function() require("dap").terminate() end, desc = "Debug: Terminate" },
		{ "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug: Toggle REPL" },
		{ "<leader>du", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
		{ "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Debug: Eval expression" },
		{ "<leader>dm", function() require("dap-python").test_method() end, desc = "Debug: Python test method" },
		{ "<leader>dM", function() require("dap-python").test_class() end, desc = "Debug: Python test class" },
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		-- UI: open/close panels automatically with the debug session
		dapui.setup()
		dap.listeners.after.event_initialized["dapui_config"] = dapui.open
		dap.listeners.before.event_terminated["dapui_config"] = dapui.close
		dap.listeners.before.event_exited["dapui_config"] = dapui.close

		vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
		vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
		vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })

		-- Python: debugpy runs from Mason's venv; the debuggee uses the project's
		-- interpreter ($VIRTUAL_ENV, ./venv or ./.venv), detected by nvim-dap-python.
		-- Test runner (<leader>dm/dM) is auto-detected: pytest if pytest.ini or [tool.pytest] exists,
		-- otherwise unittest. Force it with require("dap-python").test_runner = "pytest".
		require("dap-python").setup(mason_path .. "/packages/debugpy/venv/bin/python")
		table.insert(dap.configurations.python, {
			type = "python",
			request = "launch",
			name = "pytest: current file",
			module = "pytest",
			args = { "${file}", "-s" }, -- -s keeps stdout/stdin attached (print, breakpoint())
			console = "integratedTerminal",
		})

		-- JS/TS (Angular): vscode-js-debug, installed by Mason as js-debug-adapter
		for _, adapter in ipairs({ "pwa-node", "pwa-chrome" }) do
			dap.adapters[adapter] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					args = { mason_path .. "/packages/js-debug-adapter/js-debug/src/dapDebugServer.js", "${port}" },
				},
			}
		end

		local js_configs = {
			{
				-- Start `ng serve` first. Launches a fresh Chrome on the machine running Neovim.
				type = "pwa-chrome",
				request = "launch",
				name = "Angular: launch Chrome (localhost:4200)",
				url = "http://localhost:4200",
				webRoot = "${workspaceFolder}",
				sourceMaps = true,
			},
			{
				-- Attach to a Chrome started with --remote-debugging-port=9222.
				-- Over SSH, forward that port from the Mac: `ssh -R 9222:localhost:9222 <host>`.
				type = "pwa-chrome",
				request = "attach",
				name = "Angular: attach to Chrome (port 9222)",
				port = 9222,
				webRoot = "${workspaceFolder}",
				sourceMaps = true,
			},
			{
				type = "pwa-node",
				request = "launch",
				name = "Node: launch current file",
				program = "${file}",
				cwd = "${workspaceFolder}",
				sourceMaps = true,
			},
			{
				type = "pwa-node",
				request = "attach",
				name = "Node: attach to process",
				processId = require("dap.utils").pick_process,
				cwd = "${workspaceFolder}",
				sourceMaps = true,
			},
		}
		for _, ft in ipairs({ "typescript", "javascript", "htmlangular", "html" }) do
			dap.configurations[ft] = js_configs
		end
	end,
}
