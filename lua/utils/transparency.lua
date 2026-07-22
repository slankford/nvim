local M = {}

local defaults = {
	enabled = true,
	colorscheme = "rose-pine",
}

-- Drives rose-pine's own built-in transparency mode (styles.transparency)
-- instead of hand-clearing highlight groups. rose-pine maintains what goes
-- transparent (Normal, StatusLine, Pmenu, Telescope*, etc.) and keeps things
-- like FloatBorder's outline color even when the fill is transparent.
local function apply_rose_pine_styles()
	local ok, rose_pine = pcall(require, "rose-pine")
	if not ok then
		return
	end

	rose_pine.setup({
		styles = { transparency = vim.g.transparent_enabled },
	})
end

local function refresh_ui()
	apply_rose_pine_styles()

	local scheme = vim.g.colors_name or M.colorscheme or defaults.colorscheme
	pcall(vim.cmd.colorscheme, scheme)

	pcall(vim.api.nvim_exec_autocmds, "User", { pattern = "TransparencyToggle" })
end

function M.enable()
	vim.g.transparent_enabled = true
	refresh_ui()
end

function M.disable()
	vim.g.transparent_enabled = false
	refresh_ui()
end

function M.toggle()
	vim.g.transparent_enabled = not vim.g.transparent_enabled
	refresh_ui()
	vim.notify("Transparency " .. (vim.g.transparent_enabled and "ON" or "OFF"), vim.log.levels.INFO)
end

function M.setup(opts)
	opts = vim.tbl_extend("force", defaults, opts or {})
	M.colorscheme = opts.colorscheme

	if vim.g.transparent_enabled == nil then
		vim.g.transparent_enabled = opts.enabled
	end

	apply_rose_pine_styles()

	vim.api.nvim_create_user_command("TransparencyEnable", M.enable, {})
	vim.api.nvim_create_user_command("TransparencyDisable", M.disable, {})
	vim.api.nvim_create_user_command("TransparencyToggle", M.toggle, {})
end

return M
