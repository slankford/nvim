-- https://github.com/nvim-mini/mini.nvim/tree/main/readmes
return {
	{ "echasnovski/mini.ai", version = "*", opts = {} },
	{ "echasnovski/mini.comment", version = "*", opts = {} },
	{
		"echasnovski/mini.move",
		version = "*",
		opts = {
			mappings = {
				-- Normal mode
				line_up = "<leader>k",
				line_down = "<leader>j",
				line_left = "<leader>h",
				line_right = "<leader>l",

				-- Visual mode
				up = "<leader>k",
				down = "<leader>j",
				left = "<leader>h",
				right = "<leader>l",
			},
		},
	},
	{ "echasnovski/mini.surround", version = "*", opts = {} },
	{ "echasnovski/mini.cursorword", version = "*", opts = {} },
	{ "echasnovski/mini.indentscope", version = "*", opts = {} },
	-- {"echasnovski/mini.pairs", version="*", opts = {}},
	{ "echasnovski/mini.trailspace", version = "*", opts = {} },
	{ "echasnovski/mini.bufremove", version = "*", opts = {} },
}
