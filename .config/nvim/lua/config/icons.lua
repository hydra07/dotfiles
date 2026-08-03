-- Icon glyphs shared across config modules. `diagnostics` is used by both
-- lsp/utils.lua (sign column) and ui/lualine.lua (diagnostics component) —
-- must live here, not duplicated, so the two can never drift out of sync.
-- Everything else here just keeps lualine.lua's logic free of magic strings.
--
-- Glyphs are written as `\u{XXXX}` escapes, not literal characters: raw
-- PUA source characters have silently been stripped to blank space more
-- than once in this file's history. `\u{}` is copy-paste-proof like the
-- old `\ddd` byte escapes, but keeps the codepoint readable in the source
-- instead of needing a decoded-in-a-comment lookup.
--
-- Stick to the legacy FontAwesome/devicons PUA block (U+E000-F8FF) rather
-- than Nerd Fonts' Supplementary PUA-A (U+F0000+, the newer Material Design
-- set) — the latter needs a v3+ font and renders as a blank tofu box on
-- anything older.
return {
	diagnostics = {
		error = "\u{F057} ", -- nf-fa-times_circle
		warn = "\u{F071} ", -- nf-fa-warning
		info = "\u{F05A} ", -- nf-fa-info_circle
		hint = "\u{F0EB} ", -- nf-fa-lightbulb_o
	},
	git_branch = "\u{E725}", -- nf-dev-git_branch
	formatter = "\u{F0D0} ", -- nf-fa-magic
	lsp_client = "\u{F085} ", -- nf-fa-gear
	terminal = {
		current = "\u{25CF}", -- ● focused
		open = "\u{25CB}", -- ○ open, unfocused
		hidden = "\u{25CC}", -- ◌ running hidden
	},
}
