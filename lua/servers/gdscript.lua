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
		-- cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
		-- filetypes = { "gdscript" },
    force_setup = true, -- because the LSP is global. Read more on lsp-zero docs about this.
    single_file_support = false,
    cmd = vim.lsp.rpc.connect("127.0.0.1", 6008),
    -- cmd = {'ncat', '127.0.0.1', '6008'}, -- the important trick for Windows!
    -- root_dir = require('lspconfig.util').root_pattern('project.godot', '.git'),
		root_markers = { "project.godot", ".git" },
    filetypes = { 'gdscript' }
	})
end

return M
