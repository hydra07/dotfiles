-- Tailwind CSS LSP Configuration
return {
  -- Chỉ attach nơi thực sự có className. Bỏ "typescript"/"javascript" thuần
  -- (mặc định lspconfig có) để file .ts thường chạy thuần ts7, không kéo theo
  -- tailwind (boot 3-4s + thêm provider chậm vào blink -> trễ completion).
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
