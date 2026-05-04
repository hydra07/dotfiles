-- LSP entry point
-- Auto-loads all configs from plugins/lsp/configs/*.lua
-- To add a new language: create a new file in configs/, add server name to servers.lua
local utils = require("plugins.lsp.utils")
local servers = require("plugins.lsp.servers")

return {
  -- ── Mason: UI only ────────────────────────────────────────────────────
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {
      ui = {
        border = "single",
        icons = {
          package_installed = "●",
          package_pending = "○",
          package_uninstalled = "○",
        },
      },
    },
  },

  -- ── Tool installer: manual only ───────────────────────────────────────
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsClean" },
    opts = {
      ensure_installed = {
        "stylua",
        "prettierd",
        "black",
        "shfmt",
        "eslint_d",
        "shellcheck",
      },
      auto_update = false,
      run_on_start = false,
    },
  },

  -- ── Mason-lspconfig: server installation ──────────────────────────────
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "vtsls",
        "eslint",
        "emmet_language_server",
        "pyright",
        "lua_ls",
        "tailwindcss",
        "bashls",
        "rust_analyzer",
        "gopls",
      },
      automatic_installation = false,
    },
  },

  -- ── Core LSP ──────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- 1. Shared config for all servers
      vim.lsp.config("*", {
        capabilities = utils.capabilities(),
        root_markers = {
          ".git",
          "package.json",
          "Cargo.toml",
          "go.mod",
          "pyproject.toml",
          "setup.py",
        },
      })

      -- 2. Load all server configs from configs/*.lua
      local config_dir = vim.fn.stdpath("config") .. "/lua/plugins/lsp/configs"
      for _, file in ipairs(vim.fn.glob(config_dir .. "/*.lua", false, true)) do
        dofile(file)
      end

      -- 3. Enable servers from servers.lua
      for _, server in ipairs(servers) do
        vim.lsp.enable(server)
      end

      -- 4. UI
      if vim.o.winborder == "" then
        vim.o.winborder = "single"
      end

      -- 5. Setup diagnostics, attach logic, keymaps
      utils.setup_diagnostics()
      utils.setup_attach()
      utils.setup_keymaps()
    end,
  },
}
