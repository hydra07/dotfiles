-- LSP shared utilities: capabilities, diagnostic config, attach logic
local icons = require("config.icons")
local M = {}

--- Build capabilities (merges blink.cmp if loaded)
function M.capabilities()
  local caps = vim.lsp.protocol.make_client_capabilities()
  caps.workspace.didChangeWatchedFiles.dynamicRegistration = false
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    caps = blink.get_lsp_capabilities(caps)
  end
  return caps
end

--- Configure diagnostics UI
function M.setup_diagnostics()
  vim.diagnostic.config({
    float = {
      border = "single",
      source = "if_many",
      header = "",
      prefix = "",
    },
    virtual_text = {
      spacing = 4,
      prefix = "●",
      severity = { min = vim.diagnostic.severity.WARN },
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = icons.diagnostics.error,
        [vim.diagnostic.severity.WARN] = icons.diagnostics.warn,
        [vim.diagnostic.severity.HINT] = icons.diagnostics.hint,
        [vim.diagnostic.severity.INFO] = icons.diagnostics.info,
      },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })
  -- hover/signatureHelp border comes from vim.o.winborder (set in lsp/init.lua).
  -- Don't override vim.lsp.handlers + vim.lsp.with — deprecated as of nvim 0.11+.
end

--- LspAttach / LspDetach autocmds
function M.setup_attach()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then return end

      if client:supports_method("textDocument/documentHighlight") then
        local bufnr = args.buf
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        if line_count < 3000 then
          local hl_group = vim.api.nvim_create_augroup("LspDocHL_" .. bufnr, { clear = true })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = bufnr,
            group = hl_group,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = bufnr,
            group = hl_group,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end

      if client:supports_method("textDocument/codeLens")
        and client.name ~= "vtsls"
        and client.name ~= "eslint"
      then
        local bufnr = args.buf
        local cl_group = vim.api.nvim_create_augroup("LspCodeLens_" .. bufnr, { clear = true })
        vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
          buffer = bufnr,
          group = cl_group,
          callback = function()
            vim.lsp.codelens.refresh({ bufnr = bufnr })
          end,
        })
        vim.lsp.codelens.refresh({ bufnr = bufnr })
      end

      if client:supports_method("textDocument/inlayHint") then
        vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
      end
    end,
  })

  vim.api.nvim_create_autocmd("LspDetach", {
    group = vim.api.nvim_create_augroup("UserLspDetach", { clear = true }),
    callback = function(args)
      vim.lsp.buf.clear_references()
      pcall(vim.api.nvim_del_augroup_by_name, "LspDocHL_" .. args.buf)
      pcall(vim.api.nvim_del_augroup_by_name, "LspCodeLens_" .. args.buf)
    end,
  })
end

return M
