-- ================================================================================================
-- TITLE : nvim-lspconfig
-- ABOUT : Quickstart configurations for the built-in Neovim LSP client.
-- LINKS :
--   > github                  : https://github.com/neovim/nvim-lspconfig
--   > mason.nvim (dep)        : https://github.com/mason-org/mason.nvim
--   > efmls-configs-nvim (dep): https://github.com/creativenull/efmls-configs-nvim
--   > cmp-nvim-lsp (dep)      : https://github.com/hrsh7th/cmp-nvim-lsp
-- ================================================================================================

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} }, -- LSP/DAP/Linter installer & manager
		{
			"mason-org/mason-lspconfig.nvim",
			opts = {
				ensure_installed = {
					"lua_ls",
					"pyright",
					"jsonls",
					"ts_ls",
					"bashls",
					"dockerls",
					"emmet_ls",
					"yamlls",
				},
			},
		},
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			opts = {
				ensure_installed = { "efm" },
				run_on_start = true,
			},
		},
		"creativenull/efmls-configs-nvim", -- Preconfigured EFM Language Server setups
		"hrsh7th/cmp-nvim-lsp", -- nvim-cmp source for LSP-based completion
		{
			"nvimdev/lspsaga.nvim",
			dependencies = { "rcarriga/nvim-notify" },
			opts = {
				-- Make lightbulb not as annoying
				code_action_lightbulb = {
					enable = false,
					sign = false, -- optional, removes gutter signs
					virtual_text = true, -- keeps inline text lightbulb
					virtual_text_only = true,
					update_in_insert = false,
					sign_priority = 20,
					show_server_name = false,
					-- custom callback to only show for “real” code actions
					-- code_action_callback = function(actions)
					-- 	for _, a in ipairs(actions or {}) do
					-- 		if not a.title:match("Move") then
					-- 			return true
					-- 		end
					-- 	end
					-- 	return false
					-- end,
				},
				lightbulb = {
					enable = false,
				},
				-- code_action_callback = function(actions)
				-- 	for _, a in ipairs(actions or {}) do
				-- 		if not a.title:match("Move") then
				-- 			return true
				-- 		end
				-- 	end
				-- 	return false
				-- end,
			},
		},
	},
	config = function()
		require("utils.diagnostics").setup()
		require("servers")
	end,
}
