return {
  -- 	{
  -- 		dir = "D:/dev/markdown-kit.nvim/nvim/",
  -- 		name = "markdown-kit",
  -- 		ft = { "markdown" },
  -- 		cmd = {
  -- 			"MarkdownKitStart",
  -- 			"MarkdownKitStop",
  -- 			"MarkdownKitToggle",
  -- 		},
  -- 	},
  {
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && bun i",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},
}
