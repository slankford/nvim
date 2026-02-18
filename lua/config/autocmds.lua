-- ================================================================================================
-- TITLE : auto-commands
-- ABOUT : automatically run code on defined events (e.g. save, yank)
-- ================================================================================================
local on_attach = require("utils.lsp").on_attach

-- Restore last cursor position when reopening a file
local last_cursor_group = vim.api.nvim_create_augroup("LastCursorGroup", {})
vim.api.nvim_create_autocmd("BufReadPost", {
	group = last_cursor_group,
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Highlight the yanked text for 200ms
local highlight_yank_group = vim.api.nvim_create_augroup("HighlightYank", {})
vim.api.nvim_create_autocmd("TextYankPost", {
	group = highlight_yank_group,
	pattern = "*",
	callback = function()
		vim.hl.on_yank({
			higroup = "IncSearch",
			timeout = 200,
		})
	end,
})

-- format on save using efm langserver and configured formatters
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function()
		if vim.b.disable_autoformat then
			return
		end
		local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""
		if first_line:match("@noformat") then
			return
		end

		-- Save cursor position
		local pos = vim.api.nvim_win_get_cursor(0)

		-- Format only using efm
		vim.lsp.buf.format({
			filter = function(client)
				return client.name == "efm"
			end,
		})

		-- Restore cursor position
		vim.api.nvim_win_set_cursor(0, pos)
	end,
})

-- on attach function shortcuts
local lsp_on_attach_group = vim.api.nvim_create_augroup("LspMappings", {})
vim.api.nvim_create_autocmd("LspAttach", {
	group = lsp_on_attach_group,
	callback = on_attach,
})
