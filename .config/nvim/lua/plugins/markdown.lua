-- Trong file cấu hình plugin của LazyVim
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
}
