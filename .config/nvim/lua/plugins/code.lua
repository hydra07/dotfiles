return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        sh = { "shfmt" },
        bash = { "shfmt" },
        fish = { "fish_indent" },
        lua = { "stylua" },
        javascript = { "prettierd", "eslint_d", stop_after_first = false },
        typescript = { "prettierd", "eslint_d", stop_after_first = false },
        javascriptreact = { "eslint_d", "prettierd", stop_after_first = false },
        typescriptreact = { "eslint_d", "prettierd", stop_after_first = false },
        python = { "black" },
        go = { "gofumpt", "goimports-reviser", "golines" },
        rust = { "rustfmt" },
        json = { "prettierd" },
        yaml = { "prettierd" },
        markdown = { "prettierd" },
      },
      format_on_save = {
        timeout_ms = 2000,
        lsp_format = "fallback",
      },
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2" },
        },
      },
    },
  },
}
