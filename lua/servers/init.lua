-- local lspconfig = require("lspconfig")

-- lspconfig.lua_ls.setup({})
-- lspconfig.ts_ls.setup({})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Language Server Protocol (LSP)
require("servers.lua_ls").setup(capabilities)
require("servers.pyright").setup(capabilities)
-- require("servers.gopls")(capabilities)
require("servers.jsonls").setup(capabilities)
require("servers.ts_ls").setup(capabilities)
require("servers.bashls").setup(capabilities)
-- require("servers.clangd")(capabilities)
require("servers.dockerls").setup(capabilities)
require("servers.emmet_ls").setup(capabilities)
require("servers.yamlls").setup(capabilities)
-- require("servers.tailwindcss")(capabilities)
-- require("servers.solidity_ls_nomicfoundation")(capabilities)

-- Linters & Formatters
require("servers.efm-langserver").setup(capabilities)

vim.lsp.enable({
	"lua_ls",
	"pyright",
	-- 'gopls',
	"jsonls",
	"ts_ls",
	"bashls",
	-- 'clangd',
	"dockerls",
	"emmet_ls",
	"yamlls",
	-- 'tailwindcss',
	-- 'solidity_ls_nomicfoundation',
	"efm",
})
