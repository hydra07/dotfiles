-- Web: Tailwind CSS + Emmet (tag completion for JSX/HTML)

-- ── Emmet ───────────────────────────────────────────────────────────────
-- Handles tag completion, auto-closing, and emmet abbreviations in JSX/TSX/HTML
vim.lsp.config("emmet_language_server", {
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
    -- Use JSX-style self-closing tags in React files
    includeLanguages = {
      javascriptreact = "html",
      typescriptreact = "html",
    },
    -- Emmet config
    showExpandedAbbreviation = "always",
    showSuggestionsAsSnippets = true,
  },
})

-- ── Tailwind CSS ────────────────────────────────────────────────────────
-- Only attaches when tailwind config exists in project
vim.lsp.config("tailwindcss", {
  root_markers = {
    "tailwind.config.js",
    "tailwind.config.ts",
    "tailwind.config.cjs",
    "tailwind.config.mjs",
    "postcss.config.js",
    "postcss.config.ts",
  },
  settings = {
    tailwindCSS = {
      validate = true,
      -- Recognize className in JSX/TSX + common utility libs
      classAttributes = { "class", "className", "ngClass", "classList" },
      experimental = {
        classRegex = {
          { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
          { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          { "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          { "tw`([^`]*)" },
        },
      },
      lint = {
        cssConflict = "warning",
        invalidApply = "error",
        invalidScreen = "error",
        invalidVariant = "error",
      },
    },
  },
})
