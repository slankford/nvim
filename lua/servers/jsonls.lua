-- ================================================================================================
-- ================================================================================================

local M = {}

--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
function M.setup(capabilities)
	vim.lsp.config("jsonls", {
		capabilities = capabilities,
		filetypes = { "json", "jsonc" },
	})
end

return M
