-- Rust Analyzer Configuration
return {
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = true,
      check = { command = "clippy" },
      cargo = { allFeatures = true },
      procMacro = { enable = true },
      inlayHints = {
        chainingHints = { enable = true },
        closingBraceHints = { enable = true, minLines = 25 },
        parameterHints = { enable = true },
        typeHints = { enable = true },
        bindingModeHints = { enable = false },
      },
    },
  },
}
