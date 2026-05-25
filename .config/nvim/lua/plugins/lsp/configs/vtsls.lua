-- vtsls (TypeScript/JavaScript) Configuration
return {
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  settings = {
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
      suggest = { completeFunctionCalls = true },
      preferences = {
        jsxAttributeCompletionStyle = "auto",
        importModuleSpecifierPreference = "relative",
      },
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = "literals" },
        parameterTypes = { enabled = false },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = false },
      },
      tsserver = {
        maxTsServerMemory = 2048,
        experimental = {
          enableProjectDiagnostics = false,
        },
      },
    },
    javascript = {
      updateImportsOnFileMove = { enabled = "always" },
      suggest = { completeFunctionCalls = true },
      preferences = {
        jsxAttributeCompletionStyle = "auto",
        importModuleSpecifierPreference = "relative",
      },
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = "literals" },
        parameterTypes = { enabled = false },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = false },
      },
    },
    vtsls = {
      enableMoveToFileCodeAction = true,
      autoUseWorkspaceTsdk = true,
      experimental = {
        completion = {
          enableServerSideFuzzyMatch = true,
          entriesLimit = 100,
        },
      },
    },
  },
}
