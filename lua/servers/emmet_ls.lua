-- ================================================================================================
-- ================================================================================================

local M = {}

--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
function M.setup(capabilities)
	vim.lsp.config("emmet_ls", {
		capabilities = capabilities,
		filetypes = {
			"typeScript",
			"javascript",
			"javascriptreact",
			"typescriptreact",
			"css",
			"sass",
			"scss",
			"svelte",
			"vue",
		},
	})
end

return M
