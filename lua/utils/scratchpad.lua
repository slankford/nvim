local M = {}

local scratchpad_path = vim.fn.expand("~/.local/share/nvim/scratchpad.md")

local function ensure_file(path)
	if vim.fn.filereadable(path) == 1 then
		return
	end

	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
	vim.fn.writefile({ "# Scratchpad", "" }, path)
end

function M.path()
	return scratchpad_path
end

function M.toggle()
	ensure_file(scratchpad_path)

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.api.nvim_buf_get_name(buf) == scratchpad_path then
			vim.api.nvim_win_close(win, true)
			return
		end
	end

	local buf = vim.fn.bufadd(scratchpad_path)
	vim.fn.bufload(buf)

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)

	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		border = "rounded",
	})
end

function M.setup_autosave()
	local group = vim.api.nvim_create_augroup("ScratchpadAutosave", { clear = true })

	vim.api.nvim_create_autocmd({ "BufWinLeave", "BufHidden", "VimLeavePre" }, {
		group = group,
		callback = function(args)
			local buf = args.buf
			if not buf or not vim.api.nvim_buf_is_valid(buf) then
				return
			end

			if vim.api.nvim_buf_get_name(buf) ~= scratchpad_path then
				return
			end

			if vim.bo[buf].modified and vim.bo[buf].buftype == "" then
				vim.api.nvim_buf_call(buf, function()
					vim.cmd("silent! write")
				end)
			end
		end,
	})
end

return M
