return {
  "lukas-reineke/virt-column.nvim",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local function set_highlight()
      vim.api.nvim_set_hl(0, "VirtColumn", { fg = "#403d52", bg = "none", nocombine = true })
    end

    set_highlight()

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("VirtColumnHighlight", { clear = true }),
      callback = set_highlight,
    })

    require("virt-column").setup({
      char = "│",
      virtcolumn = "100",
      highlight = "VirtColumn",
    })
  end,
}
