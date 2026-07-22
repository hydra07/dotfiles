local keymaps = require("config.keymaps")

return {
	keys = {
		keymaps.bind("file_browser_cwd", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>"),
		keymaps.bind("file_browser_root", "<cmd>Telescope file_browser<cr>"),
	},
	-- Deferred: telescope.extensions.file_browser.actions only exists once the
	-- file_browser extension itself has loaded (a telescope dependency), so this
	-- must run from inside telescope's own config(), not at plugin-spec-build time.
	settings = function()
		local fb_actions = require("telescope").extensions.file_browser.actions
		return {
			hijack_netrw = true,
			hidden = true,
			mappings = {
				["i"] = {
					["<C-a>"] = fb_actions.create,
					["<C-r>"] = fb_actions.rename,
					["<C-d>"] = fb_actions.remove,
					["<A-m>"] = fb_actions.move,
					["<C-h>"] = fb_actions.toggle_hidden,
				},
			},
		}
	end,
}
