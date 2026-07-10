return {
	{
		"hydra07/markdown-kit.nvim",
		branch = "runtime-linux-x64",
		ft = { "markdown" },
		-- build = "mise trust .mise.toml && mise run setup && mise run build",
		config = function()
			-- Optional: custom root path if needed
			-- vim.g.markdown_kit_root = vim.fn.stdpath("data") .. "/lazy/markdown-kit.nvim/"
		end,
	},
	-- {
	-- 	"iamcco/markdown-preview.nvim",
	-- 	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	-- 	build = "cd app && bun i",
	-- 	init = function()
	-- 		vim.g.mkdp_filetypes = { "markdown" }
	-- 	end,
	-- 	ft = { "markdown" },
	-- },
}
