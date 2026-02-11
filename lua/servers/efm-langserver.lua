-- ================================================================================================
-- TITLE : efm-langserver
-- ABOUT : a general purpose language server protocol implemented here for linters/formatters
-- LINKS :
--   > github : https://github.com/mattn/efm-langserver
--   > configs: https://github.com/creativenull/efmls-configs-nvim/tree/main
-- ================================================================================================

local M = {}

--- @param capabilities table LSP client capabilities (from nvim-cmp)
--- @return nil
function M.setup(capabilities)
	local luacheck = require("efmls-configs.linters.luacheck") -- lua linter
	local stylua = require("efmls-configs.formatters.stylua") -- lua formatter
	local flake8 = require("efmls-configs.linters.flake8") -- python linter
	local ruff = require("efmls-configs.formatters.ruff") -- python formatter
	local go_revive = require("efmls-configs.linters.go_revive") -- go linter
	local gofumpt = require("efmls-configs.formatters.gofumpt") -- go formatter
	local prettier = require("efmls-configs.formatters.prettier") -- ts/js/solidity/json/docker/html/css/react/svelte/vue formatter
	local eslint_d = require("efmls-configs.linters.eslint_d") -- ts/js/solidity/json/react/svelte/vue linter
	local fixjson = require("efmls-configs.formatters.fixjson") -- json formatter
	local shellcheck = require("efmls-configs.linters.shellcheck") -- bash linter
	local shfmt = require("efmls-configs.formatters.shfmt") -- bash formatter
	local hadolint = require("efmls-configs.linters.hadolint") -- docker linter
	local cpplint = require("efmls-configs.linters.cpplint") -- c/cpp linter
	local clangformat = require("efmls-configs.formatters.clang_format") -- c/cpp formatter
	local solhint = require("efmls-configs.linters.solhint") -- solidity linter

	vim.lsp.config("efm", {
		capabilities = capabilities,
		filetypes = {
			"c",
			"cpp",
			"css",
			"docker",
			"go",
			"html",
			"javascript",
			"javascriptreact",
			"json",
			"jsonc",
			"lua",
			"markdown",
			"python",
			"sh",
			"solidity",
			"svelte",
			"typescript",
			"typescriptreact",
			"vue",
		},
		init_options = {
			documentFormatting = true,
			documentRangeFormatting = true,
			hover = true,
			documentSymbol = true,
			codeAction = true,
			completion = true,
		},
		settings = {
			languages = {
				c = { clangformat, cpplint },
				cpp = { clangformat, cpplint },
				css = { prettier },
				docker = { hadolint, prettier },
				go = { gofumpt, go_revive },
				html = { prettier },
				javascript = { eslint_d, prettier },
				javascriptreact = { eslint_d, prettier },
				json = { eslint_d, fixjson },
				jsonc = { eslint_d, fixjson },
				lua = { luacheck, stylua },
				markdown = { prettier },
				python = { flake8, ruff },
				sh = { shellcheck, shfmt },
				solidity = { solhint, prettier },
				svelte = { eslint_d, prettier },
				typescript = { prettier, eslint_d },
				typescriptreact = { prettier, eslint_d },
				vue = { eslint_d, prettier },
			},
		},
	})
end

return M
