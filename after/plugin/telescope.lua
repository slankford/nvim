-- Telescope fuzzy finder
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'All files search' })
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'All files search' })

vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'Git files search' })
vim.keymap.set('n', '<leader>pg', builtin.git_files, { desc = 'Git files search' })

vim.keymap.set('n', '<leader>pb', builtin.buffers, { desc = 'Buffer search' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffer search' })

vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
vim.keymap.set('n', '<leader>fg', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)

vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags search' })
vim.keymap.set('n', '<leader>ph', builtin.help_tags, { desc = 'Help tags search' })

vim.keymap.set('n', '<leader>px', builtin.diagnostics, { desc = 'Diagnostics search' })
vim.keymap.set('n', '<leader>fx', builtin.diagnostics, { desc = 'Diagnostics search' })

vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Document symbol search' })

vim.keymap.set('n', '<leader>fS', builtin.lsp_workspace_symbols, { desc = 'Workspace symbol search' })
