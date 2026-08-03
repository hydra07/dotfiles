local keymaps = require("config.keymaps")

return {
	{
		"coder/claudecode.nvim",
		-- No dependencies: terminal.provider = "native" uses Neovim's own
		-- built-in terminal, so snacks.nvim (only needed for provider="snacks")
		-- is never required.
		cmd = {
			"ClaudeCode",
			"ClaudeCodeFocus",
			"ClaudeCodeSelectModel",
			"ClaudeCodeAdd",
			"ClaudeCodeSend",
			"ClaudeCodeStatus",
			"ClaudeCodeStart",
			"ClaudeCodeStop",
			"ClaudeCodeDiffAccept",
			"ClaudeCodeDiffDeny",
			"ClaudeCodeCloseAllDiffs",
		},
		opts = {
			terminal = {
				provider = "native",
			},
		},
		keys = {
			keymaps.bind("claude_toggle", "<cmd>ClaudeCode<cr>"),
			keymaps.bind("claude_focus", "<cmd>ClaudeCodeFocus<cr>"),
			keymaps.bind("claude_resume", "<cmd>ClaudeCode --resume<cr>"),
			keymaps.bind("claude_continue", "<cmd>ClaudeCode --continue<cr>"),
			keymaps.bind("claude_select_model", "<cmd>ClaudeCodeSelectModel<cr>"),
			keymaps.bind("claude_add_buffer", "<cmd>ClaudeCodeAdd %<cr>"),
			keymaps.bind("claude_send_selection", "<cmd>ClaudeCodeSend<cr>"),
			keymaps.bind("claude_diff_accept", "<cmd>ClaudeCodeDiffAccept<cr>"),
			keymaps.bind("claude_diff_deny", "<cmd>ClaudeCodeDiffDeny<cr>"),
		},
	},
}
