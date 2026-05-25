-- Server list and configurations to enable
return {
  lua_ls = require("plugins.lsp.configs.lua_ls"),
  basedpyright = require("plugins.lsp.configs.basedpyright"),
  rust_analyzer = require("plugins.lsp.configs.rust_analyzer"),
  vtsls = require("plugins.lsp.configs.vtsls"),
  eslint = require("plugins.lsp.configs.eslint"),
  emmet_language_server = require("plugins.lsp.configs.emmet_language_server"),
  tailwindcss = require("plugins.lsp.configs.tailwindcss"),
}
