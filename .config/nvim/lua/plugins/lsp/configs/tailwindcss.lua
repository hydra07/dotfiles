-- Tailwind CSS LSP Configuration
return {
  -- Only attach where className actually appears. Plain "typescript"/"javascript"
  -- (lspconfig's default) are omitted so a bare .ts file runs on ts7 alone,
  -- without dragging in tailwindcss (3-4s boot + a slower blink provider -> laggy completion).
  filetypes = {
    "html",
    "css",
    "scss",
    "less",
    "javascriptreact",
    "typescriptreact",
    "svelte",
    "vue",
    "astro",
  },
  root_markers = {
    "tailwind.config.js",
    "tailwind.config.ts",
    "tailwind.config.cjs",
    "tailwind.config.mjs",
    "postcss.config.js",
    "postcss.config.ts",
    "package.json",
    ".git",
  },
  settings = {
    tailwindCSS = {
      validate = true,
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
}
