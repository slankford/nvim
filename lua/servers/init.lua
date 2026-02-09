-- local lspconfig = require("lspconfig")
--
-- lspconfig.lua_ls.setup({})
-- lspconfig.ts_ls.setup({})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local servers = {
  "lua_ls",
  "ts_ls"
}

-- Language Server Protocol (LSP)
require("servers.lua_ls")(capabilities)
-- require("servers.pyright")(capabilities)
-- require("servers.gopls")(capabilities)
-- require("servers.jsonls")(capabilities)
require("servers.ts_ls")(capabilities)
-- require("servers.bashls")(capabilities)
-- require("servers.clangd")(capabilities)
-- require("servers.dockerls")(capabilities)
-- require("servers.emmet_ls")(capabilities)
-- require("servers.yamlls")(capabilities)
-- require("servers.tailwindcss")(capabilities)
-- require("servers.solidity_ls_nomicfoundation")(capabilities)

-- Linters & Formatters
require("servers.efm-langserver")(capabilities)

-- vim.lsp.enable({
  -- 'lua_ls',
  -- 'pyright',
  -- 'gopls',
  -- 'jsonls',
  -- 'ts_ls',
  -- 'bashls',
  -- 'clangd',
  -- 'dockerls',
  -- 'emmet_ls',
  -- 'yamlls',
  -- 'tailwindcss',
  -- 'solidity_ls_nomicfoundation',
  -- 'efm',
-- })
-- local lspconfig = require('lspconfig')
--
-- local on_attach = function(client, bufnr)
--   local keymap = vim.keymap.set
--   local opts = {
--     noremap = true,
--   }
--
-- end
--
-- lspconfig.lua_ls.setup({
--   settings = {
--     Lua = {
--       diagnostics = {
--         globals = { "vim" },
--       },
--       workspace = {
--         library = {
--           vim.fn.expand("$VIMRUNTIME/lua"),
--           vim.fn.expand("$XDG_CONFIG_HOME") .. "/nvim/lua"
--         }
--       }
--     }
--   }
-- })
