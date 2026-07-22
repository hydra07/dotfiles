return {
	{
		dir = "D:/dev/markdown-kit.nvim/nvim/",
		name = "markdown-kit",
		ft = { "markdown" },
		cmd = {
			"MarkdownKitStart",
			"MarkdownKitStop",
			"MarkdownKitToggle",
		},
	},
	-- {
	-- 	"hydra07/markdown-kit.nvim",
	-- 	branch = "runtime-windows-x64",
	-- 	ft = { "markdown" },
	-- 	-- build = "mise trust .mise.toml && mise run setup && mise run build",
	-- 	config = function()
	-- 		-- Optional: custom root path if needed
	-- 		-- vim.g.markdown_kit_root = vim.fn.stdpath("data") .. "/lazy/markdown-kit.nvim/"
	-- 	end,
	-- },
}
