-- ================================================================================================
-- ================================================================================================

local M = {}

--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
function M.setup(capabilities)
	vim.lsp.config("dockerls", {
		capabilities = capabilities,
		filetypes = { "dockerfile" },
	})
end

return M
