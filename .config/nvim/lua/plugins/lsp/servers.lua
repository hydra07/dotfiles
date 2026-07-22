local ts_engine = "ts7"
local servers = {
	lua_ls = require("plugins.lsp.configs.lua_ls"),
	basedpyright = require("plugins.lsp.configs.basedpyright"),
	rust_analyzer = require("plugins.lsp.configs.rust_analyzer"),
	eslint = require("plugins.lsp.configs.eslint"),
	emmet_language_server = require("plugins.lsp.configs.emmet_language_server"),
	tailwindcss = require("plugins.lsp.configs.tailwindcss"),
}

if ts_engine == "ts7" then
	servers.ts7 = require("plugins.lsp.configs.ts7")
else
	servers.vtsls = require("plugins.lsp.configs.vtsls")
end

return servers
