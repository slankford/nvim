-- ================================================================================================
-- TITLE : globals
-- ABOUT : q:^)
-- ================================================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

if vim.nonnil == nil and vim.F and vim.F.if_nil then
  vim.nonnil = vim.F.if_nil
end
