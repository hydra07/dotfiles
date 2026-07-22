local keymaps = require("config.keymaps")

-- Press 's' to jump anywhere (like Cursor/VSCode Jump)
local function flash_jump()
	require("flash").jump()
end

-- Press 'S' to select code blocks quickly (functions, brackets, if/else) using Treesitter
local function flash_treesitter()
	require("flash").treesitter()
end

-- Press 'r' in visual mode to select surrounding area
local function flash_remote()
	require("flash").remote()
end

local function flash_treesitter_search()
	require("flash").treesitter_search()
end

return {
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			jump = {
				nohlsearch = true,
			},
			labels = "asdfghjklqwertyuiopzxcvbnm",
			label = {
				after = true,
				highlight = {
					backdrop = true,
				},
			},
			search = {
				enabled = true,
				multi_window = false,
			},
			modes = {
				char = {
					enabled = true,
					keys = { "f", "F", "t", "T" },
					jump_labels = true,
				},
				search = {
					enabled = true,
				},
			},
			prompts = {
				enabled = true,
				-- prefix = { { "⚡", "FlashPromptIcon" } },
			},
		},
		keys = {
			keymaps.bind("flash_jump", flash_jump),
			keymaps.bind("flash_treesitter", flash_treesitter),
			keymaps.bind("flash_remote", flash_remote),
			keymaps.bind("flash_treesitter_search", flash_treesitter_search),
		},
	},
}
