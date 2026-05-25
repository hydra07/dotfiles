-- Emmet LSP Configuration
return {
  filetypes = {
    "html",
    "css",
    "scss",
    "less",
    "javascriptreact",
    "typescriptreact",
    "javascript.jsx",
    "typescript.tsx",
  },
  init_options = {
    includeLanguages = {
      javascriptreact = "html",
      typescriptreact = "html",
    },
    showExpandedAbbreviation = "always",
    showSuggestionsAsSnippets = true,
  },
}
