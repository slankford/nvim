return {
	"nvim-lualine/lualine.nvim",
	config = function()
		local function lualine_theme()
			local theme = require("lualine.themes.rose-pine")
			theme = vim.deepcopy(theme)

			local mode_fg = "#faf4ed"
			local location_fg = "#f6c177"

			for _, mode in pairs(theme) do
				if mode.a then
					mode.a.bg = "none"
					mode.a.fg = mode_fg
					mode.a.gui = "bold"
				end
				if mode.b then
					mode.b.bg = "none"
				end
				if mode.c then
					mode.c.bg = "none"
				end
				if mode.y then
					mode.y.bg = "none"
				end
				if mode.z then
					mode.z.bg = "none"
					mode.z.fg = location_fg
					mode.z.gui = "bold"
				end
			end

			return theme
		end

		local function setup_lualine()
			local transparent = vim.g.transparent_enabled
			require("lualine").setup({
				options = {
					theme = transparent and lualine_theme() or "rose-pine",
					icons_enabled = true,
					section_separators = { left = "", right = "" },
					component_separators = "|",
				},
			})
		end

		setup_lualine()

		local group = vim.api.nvim_create_augroup("LualineTransparency", { clear = true })
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "TransparencyToggle",
			callback = setup_lualine,
		})
	end,
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
