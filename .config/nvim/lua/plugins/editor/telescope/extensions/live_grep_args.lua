local keymaps = require("config.keymaps")

local function live_grep_args()
	require("telescope").extensions.live_grep_args.live_grep_args({
		additional_args = { "--hidden" },
		cache_picker = false,
	})
end

local function grep_word_under_cursor()
	require("telescope-live-grep-args.shortcuts").grep_word_under_cursor({
		postfix = "",
		quote = true,
		trim = true,
		additional_args = { "--hidden" },
		cache_picker = false,
	})
end

local function grep_visual_selection()
	require("telescope-live-grep-args.shortcuts").grep_visual_selection({
		postfix = "",
		quote = true,
		trim = true,
		additional_args = { "--hidden" },
		cache_picker = false,
	})
end

return {
	keys = {
		keymaps.bind("live_grep_args", live_grep_args),
		keymaps.bind("grep_word_under_cursor", grep_word_under_cursor),
		keymaps.bind("grep_visual_selection", grep_visual_selection),
	},
	settings = function()
		return {
			auto_quoting = true,
			debounce = 100,
		}
	end,
}
