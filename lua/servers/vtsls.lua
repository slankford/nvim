local M = {}
function M.setup(capabilities)
	vim.lsp.config("vtsls", {
		capabilities = capabilities,
		filetypes = {
			"typescript",
			"javascript",
			"typescriptreact",
			"javascriptreact",
		},
		settings = {
			vtsls = {
				autoUseWorkspaceTsdk = true,
			},
			typescript = {
				indentStyle = "space",
				indentSize = 2,
			},
		},
		on_attach = function(client)
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false
		end,
	})
end
return M
