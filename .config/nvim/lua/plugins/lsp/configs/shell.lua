-- Shell: bashls
vim.lsp.config("bashls", {
  settings = {
    bashIde = { globPattern = "*@(.sh|.inc|.bash|.command)" },
  },
})
