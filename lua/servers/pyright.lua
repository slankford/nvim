-- ================================================================================================
-- ================================================================================================

local M = {}

--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
function M.setup(capabilities)
	vim.lsp.config("pyright", {
		capabilities = capabilities,
		settings = {
			python = {
				disableOrganizeImports = false,
				analysis = {
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
