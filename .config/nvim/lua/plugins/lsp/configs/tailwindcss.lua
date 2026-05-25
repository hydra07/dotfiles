-- Tailwind CSS LSP Configuration
return {
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
