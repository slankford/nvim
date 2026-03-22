-- ================================================================================================
-- TITLE : gdscript (Godot Language Server) LSP Setup
-- LINKS :
--   > docs: https://docs.godotengine.org/en/stable/tutorials/editor/external_editor.html
-- ================================================================================================

local M = {}

--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
function M.setup(capabilities)
	vim.lsp.config("gdscript", {
		capabilities = capabilities,
		cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
		filetypes = { "gdscript" },
		root_markers = { "project.godot", ".git" },
	})
end

return M
