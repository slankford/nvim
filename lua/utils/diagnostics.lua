local M = {}

local diagnostic_signs = {
	Error = " ",
	Warn = " ",
	Hint = "",
	Info = "",
}

-- Over SSH, TERM_PROGRAM isn't forwarded, so nvim can't tell WezTerm supports undercurl
-- (TERM is xterm-256color) and draws no diagnostic underline at all. Use a plain underline there.
local function use_plain_underline()
	for _, severity in ipairs({ "Error", "Warn", "Info", "Hint", "Ok" }) do
		local group = "DiagnosticUnderline" .. severity
		local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
		hl.undercurl = nil
		hl.underline = true
		hl.cterm = { underline = true }
		vim.api.nvim_set_hl(0, group, hl)
	end
end

M.setup = function()
	if vim.env.SSH_TTY then
		use_plain_underline()
		-- Re-apply after colorscheme reloads (e.g. the transparency toggle)
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("DiagnosticPlainUnderline", {}),
			callback = use_plain_underline,
		})
	end

	vim.diagnostic.config({
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
				[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
				[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
				[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
			},
		},
	})
end

return M
