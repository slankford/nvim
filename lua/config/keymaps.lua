-- @noformat
-- ================================================================================================
-- TITLE: NeoVim keymaps
-- ABOUT: sets some quality-of-life keymaps
-- ================================================================================================

local map = vim.keymap.set
local opts = { silent = true }

-- Center screen when jumping
-- vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
-- vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Better J behavior
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- Quick config editing
vim.keymap.set("n", "<leader>rc", "<Cmd>e ~/.config/nvim/init.lua<CR>", { desc = "Edit config" })

-- Probably not needed
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("n", "gx", function()
	vim.ui.open(vim.fn.expand("<cfile>"))
end, { desc = "Open URL via macOS" })

-- ==================== VSCode / Neovim unified shortcuts ====================
-- Same keys: VSCode/Cursor actions when inside editor, Neovim equivalents when standalone.
if vim.g.vscode then
	-- C-h / C-l: switch editors (prev/next tab)
	map("n", "<C-h>", function()
		vim.fn.VSCodeNotify("workbench.action.previousEditor")
	end, opts)
	map("n", "<C-l>", function()
		vim.fn.VSCodeNotify("workbench.action.nextEditor")
	end, opts)
	map("v", "<C-h>", function()
		vim.fn.VSCodeNotify("workbench.action.previousEditor")
	end, opts)
	map("v", "<C-l>", function()
		vim.fn.VSCodeNotify("workbench.action.nextEditor")
	end, opts)

	map("v", "<leader>bn", function()
		vim.fn.VSCodeNotify("workbench.action.nextEditor")
	end, { desc = "Next editor" })
	map("n", "<leader>bn", function()
		vim.fn.VSCodeNotify("workbench.action.nextEditor")
	end, { desc = "Next editor" })
	map("v", "<leader>bp", function()
		vim.fn.VSCodeNotify("workbench.action.previousEditor")
	end, { desc = "Previous editor" })
	map("n", "<leader>bp", function()
		vim.fn.VSCodeNotify("workbench.action.previousEditor")
	end, { desc = "Previous editor" })
	-- Splitting like Neovim (VSCode split editor mappings)
	map("n", "<leader>sv", function()
		vim.fn.VSCodeNotify("workbench.action.splitEditorRight")
	end, opts) -- Split window vertically
	map("n", "<leader>sh", function()
		vim.fn.VSCodeNotify("workbench.action.splitEditorDown")
	end, opts) -- Split window horizontally
	-- leader h/j/k/l: focus panes
	-- map("n", "<leader>h", function() vim.fn.VSCodeNotify("workbench.action.focusLeftGroup") end, opts)
	-- map("n", "<leader>j", function() vim.fn.VSCodeNotify("workbench.action.focusBelowGroup") end, opts)
	-- map("n", "<leader>k", function() vim.fn.VSCodeNotify("workbench.action.focusAboveGroup") end, opts)
	-- map("n", "<leader>l", function() vim.fn.VSCodeNotify("workbench.action.focusRightGroup") end, opts)
	-- leader o: close other editors
	map("n", "<leader>o", function()
		vim.fn.VSCodeNotify("workbench.action.closeOtherEditors")
	end, opts)
	-- leader w: save file
	map("n", "<leader>w", function()
		vim.fn.VSCodeNotify("workbench.action.files.save")
	end, opts)
	-- leader q: close editor/tab
	map("n", "<leader>q", function()
		vim.fn.VSCodeNotify("workbench.action.closeActiveEditor")
	end, opts)
	-- leader f: quick open
	map("n", "<leader>f", function()
		vim.fn.VSCodeNotify("workbench.action.quickOpen")
	end, opts)
	-- leader p: format document
	-- map("n", "<leader>p", function() vim.fn.VSCodeNotify("editor.action.formatDocument") end, opts)
	-- leader ca: quick fix
	map("n", "<leader>ca", function()
		vim.fn.VSCodeNotify("editor.action.quickFix")
	end, opts)
	-- gh: hover preview
	map("n", "gh", function()
		vim.fn.VSCodeNotify("editor.action.showDefinitionPreviewHover")
	end, opts)
	-- leader u, gr: go to references
	map("n", "<leader>u", function()
		vim.fn.VSCodeNotify("editor.action.referenceSearch.trigger")
	end, opts)
	map("n", "gr", function()
		vim.fn.VSCodeNotify("editor.action.referenceSearch.trigger")
	end, { noremap = true, silent = true })

	-- native neovim keymaps
	map("n", "<leader>gd", function()
		vim.fn.VSCodeNotify("editor.action.peekDefinition")
	end, opts) -- goto definition
	map("n", "<leader>gD", function()
		vim.fn.VSCodeNotify("editor.action.revealDefinition")
	end, opts) -- goto definition
	map("n", "<leader>gS", function()
		vim.fn.VSCodeNotify("workbench.action.splitEditorRight")
		vim.fn.VSCodeNotify("editor.action.revealDefinition")
	end, opts) -- goto definition in split
	map("n", "<leader>ca", function()
		vim.fn.VSCodeNotify("editor.action.quickFix")
	end, opts) -- Code actions
	map("n", "<leader>rn", function()
		vim.fn.VSCodeNotify("editor.action.rename")
	end, opts) -- Rename symbol
	map("n", "<leader>D", function()
		vim.fn.VSCodeNotify("editor.action.showHover")
	end, opts) -- Show hover (roughly like diagnostics)
	map("n", "<leader>d", function()
		vim.fn.VSCodeNotify("editor.action.showHover")
	end, opts) -- Show hover
	map("n", "<leader>pd", function()
		vim.fn.VSCodeNotify("editor.action.marker.prev")
	end, opts) -- previous diagnostic
	map("n", "<leader>nd", function()
		vim.fn.VSCodeNotify("editor.action.marker.next")
	end, opts) -- next diagnostic
	map("n", "K", function()
		vim.fn.VSCodeNotify("editor.action.showHover")
	end, opts) -- hover documentation

	-- NvimTree VSCode equivalents
	map("n", "<leader>m", function()
		vim.fn.VSCodeNotify("workbench.view.explorer")
	end, { desc = "Focus on file explorer (VSCode)" })
	map("n", "<leader>e", function()
		vim.fn.VSCodeNotify("workbench.action.closeSidebar")
	end, { desc = "Minimize (close) explorer sidebar (VSCode)" })

	-- VSCode equivalent mappings for common Telescope commands
	-- All files search (Quick Open)
	map("n", "<leader>pf", function()
		vim.fn.VSCodeNotify("workbench.action.quickOpen")
	end, { desc = "All files search" })
	map("n", "<leader>ff", function()
		vim.fn.VSCodeNotify("workbench.action.quickOpen")
	end, { desc = "All files search" })

	-- Git files search (Quick Open, filtered to Git tracked files)
	map("n", "<C-p>", function()
		vim.fn.VSCodeNotify("workbench.action.quickOpen")
	end, { desc = "Git files search" })
	map("n", "<leader>pg", function()
		vim.fn.VSCodeNotify("workbench.action.quickOpen")
	end, { desc = "Git files search" })

	-- Buffer search (Open Editors picker)
	map("n", "<leader>pb", function()
		vim.fn.VSCodeNotify("workbench.action.showAllEditors")
	end, { desc = "Buffer search" })
	map("n", "<leader>fb", function()
		vim.fn.VSCodeNotify("workbench.action.showAllEditors")
	end, { desc = "Buffer search" })

	-- String grep search (Search across files)
	map("n", "<leader>ps", function()
		vim.fn.VSCodeNotify("workbench.action.findInFiles")
	end, { desc = "Grep string in files" })
	map("n", "<leader>fg", function()
		vim.fn.VSCodeNotify("workbench.action.findInFiles")
	end, { desc = "Grep string in files" })

	-- Help tags search (Show Command Palette)
	map("n", "<leader>fh", function()
		vim.fn.VSCodeNotify("workbench.action.showCommands")
	end, { desc = "Commands search" })
	map("n", "<leader>ph", function()
		vim.fn.VSCodeNotify("workbench.action.showCommands")
	end, { desc = "Commands search" })

	-- Diagnostics search (Show Problems view)
	map("n", "<leader>px", function()
		vim.fn.VSCodeNotify("workbench.actions.view.problems")
	end, { desc = "Diagnostics search" })
	map("n", "<leader>fx", function()
		vim.fn.VSCodeNotify("workbench.actions.view.problems")
	end, { desc = "Diagnostics search" })

	-- Document symbol search (Go to Symbol in Editor)
	map("n", "<leader>fs", function()
		vim.fn.VSCodeNotify("workbench.action.gotoSymbol")
	end, { desc = "Document symbol search" })

	-- Workspace symbol search (Go to Symbol in Workspace)
	map("n", "<leader>fS", function()
		vim.fn.VSCodeNotify("workbench.action.showAllSymbols")
	end, { desc = "Workspace symbol search" })
else
	-- Neovim: window navigation and LSP equivalents
	map("n", "<leader>bn", "<Cmd>bnext<CR>", { desc = "Next buffer" })
	map("n", "<leader>bp", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })

	map("n", "<leader>sv", "<Cmd>vsplit<CR>", { desc = "Split window vertically" })
	map("n", "<leader>ss", "<Cmd>split<CR>", { desc = "Split window horizontally" })

	-- leader w: save file
	map("n", "<leader>w", ":w<CR>", opts)
	-- leader q: close editor/tab
	map("n", "<leader>q", ":q<CR>", opts)

	vim.keymap.set("n", "<leader>tf", function()
		vim.b.disable_autoformat = not vim.b.disable_autoformat
		print("Autoformat:", vim.b.disable_autoformat and "OFF" or "ON")
	end, { desc = "Toggle format on save (buffer)" })

	map("n", "<leader>ca", function()
		vim.lsp.buf.code_action()
	end, { desc = "Code action" })
	map("n", "gh", function()
		vim.lsp.buf.hover()
	end, { desc = "Hover" })
	map("n", "gr", function()
		vim.lsp.buf.references()
	end, { noremap = true, silent = true, desc = "References" })
end
