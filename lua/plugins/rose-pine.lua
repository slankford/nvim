-- lua/plugins/rose-pine.lua
return {
	"rose-pine/neovim",
	name = "rose-pine",
	lazy = false,
	priority = 1000, -- low
	config = function()
		local transparency = require("utils.transparency")
		transparency.setup({
			enabled = true,
			colorscheme = "rose-pine",
		})

		vim.cmd("colorscheme rose-pine")
		transparency.apply()
	end,
}
