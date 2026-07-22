-- Icon tables for the blink.cmp completion menu.
local M = {}

-- Standard LSP CompletionItemKind names, sourced from mini.icons (category
-- "lsp") instead of hand-typed glyphs. Safe to build eagerly here: blink.cmp's
-- opts only run once it loads (event = "InsertEnter"), by which point
-- mini.nvim (lazy = false) is already loaded. Falls back to an empty table
-- (blink then uses its own ctx.kind_icon) if mini.icons is ever unavailable.
local kinds = {
	"Text",
	"Method",
	"Function",
	"Constructor",
	"Field",
	"Variable",
	"Class",
	"Interface",
	"Module",
	"Property",
	"Unit",
	"Value",
	"Enum",
	"Keyword",
	"Snippet",
	"Color",
	"File",
	"Reference",
	"Folder",
	"EnumMember",
	"Constant",
	"Struct",
	"Event",
	"Operator",
	"TypeParameter",
}

local function build_kind_icons()
	local ok, mini_icons = pcall(require, "mini.icons")
	if not ok then
		return {}
	end
	local icons = {}
	for _, kind in ipairs(kinds) do
		local icon_ok, icon = pcall(mini_icons.get, "lsp", kind)
		if icon_ok and icon and icon ~= "" then
			icons[kind] = icon
		end
	end
	return icons
end

M.kind_icons = build_kind_icons()

M.source_labels = {
	lsp = "[LSP]",
	path = "[Path]",
	snippets = "[Snip]",
	buffer = "[Buf]",
	cmdline = "[Cmd]",
}

return M
