-- Shared between ts7.lua and vtsls.lua (only one is ever registered at a time,
-- picked by `ts_engine` in servers.lua) so the two stay in sync by construction.
local M = {}

M.root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" }

M.inlay_hints = {
	enumMemberValues = { enabled = true },
	functionLikeReturnTypes = { enabled = true },
	parameterNames = { enabled = "literals" },
	parameterTypes = { enabled = false },
	propertyDeclarationTypes = { enabled = true },
	variableTypes = { enabled = false },
}

return M
