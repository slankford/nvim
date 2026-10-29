-- ================================================================================================
-- TITLE : basedpyright
-- ABOUT : Pyright fork that adds Pylance-only features, e.g. the "Import X from Y" code action
--   on undefined names. Replaces pyright (servers/pyright.lua is kept but not enabled).
-- LINKS :
--   > docs : https://docs.basedpyright.com/latest/configuration/language-server-settings/
-- ================================================================================================

local M = {}

--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
function M.setup(capabilities)
	vim.lsp.config("basedpyright", {
		capabilities = capabilities,
		settings = {
			basedpyright = {
				disableOrganizeImports = false,
				analysis = {
					-- basedpyright defaults to "recommended" (much stricter); match pyright's checks
					typeCheckingMode = "standard",
					autoSearchPaths = true,
					diagnosticMode = "workspace",
					useLibraryCodeForTypes = true,
					autoImportCompletions = true,
				},
			},
		},
	})
end

return M
