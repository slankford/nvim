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
			colorscheme = "rose-pine-moon",
		})

		vim.cmd("colorscheme rose-pine-moon")
		transparency.apply()

    -- Godot specific highlighting fixes
    local function apply_gdscript_ts_highlights()
      vim.api.nvim_set_hl(0, "@function.call.gdscript", { link = "Function" })
      vim.api.nvim_set_hl(0, "@function.method.call.gdscript", { link = "Function" })
      vim.api.nvim_set_hl(0, "@constructor.gdscript", { link = "Type" })
      vim.api.nvim_set_hl(0, "@property.gdscript", { link = "Identifier" })
      vim.api.nvim_set_hl(0, "@variable.parameter.gdscript", { link = "Identifier" })
      vim.api.nvim_set_hl(0, "@keyword.function.gdscript", { link = "Keyword" })
    end

    apply_gdscript_ts_highlights()

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = apply_gdscript_ts_highlights,
    })
	end,
}
