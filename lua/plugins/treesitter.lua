-- ================================================================================================
-- TITLE : nvim-treesitter (main branch)
-- ABOUT : Installs treesitter parsers/queries. Highlighting, folds and incremental selection are
--   built into Neovim 0.12+; this plugin only manages parsers and provides indentexpr.
--   Requires tree-sitter-cli >= 0.26.1 (not from npm) and a C compiler on PATH.
-- LINKS :
--   > github : https://github.com/nvim-treesitter/nvim-treesitter/tree/main
--   > docs   : :h treesitter-highlight, :h treesitter-incremental-selection
-- ================================================================================================

local parsers = {
	"angular",
	"bash",
	"css",
	"dockerfile",
	"gdscript",
	"gdshader",
	"godot_resource",
	"html",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"python",
	"scss",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

--- Start treesitter highlighting, indent and node-selection keymaps for a buffer.
--- @param buf integer
--- @param lang string
local function attach(buf, lang)
	if not vim.api.nvim_buf_is_valid(buf) or not pcall(vim.treesitter.start, buf, lang) then
		return
	end
	vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

	-- Incremental selection via Neovim 0.12 built-ins (v_an / v_in)
	vim.keymap.set("n", "<CR>", "van", { buffer = buf, remap = true, desc = "Start node selection" })
	vim.keymap.set("x", "<CR>", "an", { buffer = buf, remap = true, desc = "Expand node selection" })
	vim.keymap.set("x", "<S-TAB>", "in", { buffer = buf, remap = true, desc = "Shrink node selection" })
end

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false, -- main branch does not support lazy-loading
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")
		ts.install(parsers) -- async; already-installed parsers are skipped

		local available = nil -- installable parsers, looked up on first use

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("TreesitterStart", {}),
			callback = function(args)
				local buf = args.buf
				local lang = vim.treesitter.language.get_lang(args.match)
				if not lang then
					return
				end

				if vim.tbl_contains(ts.get_installed(), lang) then
					attach(buf, lang)
					return
				end

				-- Auto-install missing parsers when available (replaces master's auto_install)
				available = available or ts.get_available()
				if vim.tbl_contains(available, lang) then
					ts.install(lang):await(function(err)
						if not err then
							vim.schedule(function()
								attach(buf, lang)
							end)
						end
					end)
				end
			end,
		})
	end,
}
