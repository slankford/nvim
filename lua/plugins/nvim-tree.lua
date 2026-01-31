return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
	  -- Remove background color form NvimTree window
	  vim.cmd([[hi NvimTreeNormal guibg=NONE ctermbg=NONE]])
	  require("nvim-tree").setup {
		  filters = {
			  dotfiles = false, -- Show hidden files (dotfiles)
		  },
		  view = {
			  adaptive_size = true,
		  }
	  }
  end,
}
