-- Go: gopls
vim.lsp.config("gopls", {
  settings = {
    gopls = {
      completeUnimported = true,
      staticcheck = true,
      usePlaceholders = true,
      analyses = { unusedparams = true, shadow = true },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})
