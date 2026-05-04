-- TypeScript/JavaScript: vtsls + ESLint
-- Handles: .ts, .tsx, .js, .jsx

-- ── vtsls ──────────────────────────────────────────────────────────────
vim.lsp.config("vtsls", {
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
      -- JSX/TSX: tell vtsls about React JSX transform
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
})

-- ── ESLint ──────────────────────────────────────────────────────────────
vim.lsp.config("eslint", {
  root_markers = {
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.json",
    ".eslintrc.yaml",
    ".eslintrc.yml",
    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
  },
  settings = {
    workingDirectories = { mode = "auto" },
    format = true,
    run = "onSave",
    quiet = false,
    onIgnoredFiles = "off",
    problems = { shortenToSingleLine = false },
  },
  on_attach = function(_, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
})
