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
		local bufnr = vim.api.nvim_get_current_buf()
		local filetype = vim.bo[bufnr].filetype
		local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
		if first_line:match("@noformat") then
			return
		end

		-- Save cursor position
		local pos = vim.api.nvim_win_get_cursor(0)

		if filetype == "gdscript" then
			local gdformat_exe = vim.fn.exepath("gdformat")
			if gdformat_exe == "" then
				gdformat_exe = vim.fn.stdpath("data") .. "/mason/bin/gdformat.cmd"
			end

			local tmp = vim.fn.tempname() .. ".gd"
			local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
			local in_file = io.open(tmp, "wb")
			if not in_file then
				vim.notify("[Format] Failed to create temp file for gdformat.", vim.log.levels.WARN)
				return
			end
			in_file:write(table.concat(lines, "\n"))
			in_file:close()

			vim.fn.system({ gdformat_exe, tmp })
			if vim.v.shell_error ~= 0 then
				vim.fn.delete(tmp)
				vim.notify("[Format] gdformat failed.", vim.log.levels.WARN)
				return
			end

			local out_file = io.open(tmp, "rb")
			if not out_file then
				vim.fn.delete(tmp)
				vim.notify("[Format] Failed to read gdformat output.", vim.log.levels.WARN)
				return
			end
			local formatted = out_file:read("*a") or ""
			out_file:close()
			vim.fn.delete(tmp)

			formatted = formatted:gsub("\r\n", "\n")
			formatted = formatted:gsub("\r", "\n")
			if formatted:sub(-1) == "\n" then
				formatted = formatted:sub(1, -2)
			end

			vim.bo[bufnr].fileformat = "unix"
			local formatted_lines = {}
			if formatted ~= "" then
				formatted_lines = vim.split(formatted, "\n", { plain = true })
			end
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted_lines)
			vim.api.nvim_win_set_cursor(0, pos)
			return
		end

		local has_efm_formatter = false
		local function efm_attached()
			for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
				if client.name == "efm" then
					return true
				end
			end
			return false
		end

		has_efm_formatter = efm_attached()
		if not has_efm_formatter then
			vim.lsp.enable("efm")
			vim.wait(250, efm_attached, 25)
			has_efm_formatter = efm_attached()
		end

		if not has_efm_formatter then
			vim.notify(
				("[LSP] efm formatter unavailable for filetype '%s'."):format(filetype ~= "" and filetype or "unknown"),
				vim.log.levels.WARN
			)
			return
		end

		-- Format only using efm
		vim.lsp.buf.format({
			bufnr = bufnr,
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
