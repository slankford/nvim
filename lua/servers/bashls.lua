-- ================================================================================================
-- ================================================================================================

local M = {}

--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
function M.setup(capabilities)
	vim.lsp.config("bashls", {
		capabilities = capabilities,
    filetypes = {"sh", "bash", "zsh"},
	})
end

return M
