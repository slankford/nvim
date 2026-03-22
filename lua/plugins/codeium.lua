-- ================================================================================================
-- TITLE : codeium/windsurf
-- LINKS :
--   > github : https://github.com/Exafunction/windsurf.nvim
-- ABOUT : Native Windsurf plugin for Neovim.
-- ================================================================================================

return {
	"Exafunction/windsurf.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
	},
	config = function()
		local sysname = vim.loop.os_uname().sysname

		if sysname == "Linux" then
			return
		end

		if sysname == "Windows_NT" then
			local windows_setup_opts = {
				tools = {},
			}

			local curl_home = vim.fn.stdpath("cache") .. "/curl"
			vim.fn.mkdir(curl_home, "p")
			vim.fn.writefile({ "ssl-no-revoke" }, curl_home .. "/_curlrc")
			vim.fn.writefile({ "ssl-no-revoke" }, curl_home .. "/.curlrc")
			vim.env.CURL_HOME = curl_home

			local codeium_io = require("codeium.io")
			codeium_io.gunzip = function(path, callback)
				local script_path = vim.fn.stdpath("data") .. "/lazy/windsurf.nvim/lua/powershell/gzip.ps1"

				if vim.fn.filereadable(script_path) ~= 1 then
					callback(nil, "missing gzip fallback script: " .. script_path)
					return
				end

				local shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
				local command = "& { . "
					.. vim.fn.shellescape(script_path)
					.. "; Expand-File "
					.. vim.fn.shellescape(path)
					.. " }"

				vim.fn.system({
					shell,
					"-NoLogo",
					"-NoProfile",
					"-ExecutionPolicy",
					"RemoteSigned",
					"-Command",
					command,
				})

				if vim.v.shell_error ~= 0 then
					callback(nil, "failed to unpack server with PowerShell")
					return
				end

				callback()
			end

			local cache_bin = vim.fn.stdpath("cache") .. "/codeium/bin"
			local language_servers = vim.fn.glob(cache_bin .. "/*/language_server_windows_x64.exe", true, true)

			if #language_servers == 0 then
				require("codeium").setup(windows_setup_opts)
				vim.schedule(function()
					vim.notify(
						"Windsurf on Windows will auto-download the language server with --ssl-no-revoke.",
						vim.log.levels.INFO
					)
				end)
				return
			end

			table.sort(language_servers)
			windows_setup_opts.tools.language_server = language_servers[#language_servers]
			require("codeium").setup({
				tools = windows_setup_opts.tools,
			})
			return
		end

		require("codeium").setup({})
	end,
}
