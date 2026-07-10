-- LSP shared utilities: capabilities, diagnostic config, keymaps, attach logic
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
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN] = " ",
        [vim.diagnostic.severity.HINT] = "󰌵 ",
        [vim.diagnostic.severity.INFO] = " ",
      },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })
  -- Border của hover/signatureHelp lấy từ vim.o.winborder (set ở lsp/init.lua).
  -- KHÔNG override vim.lsp.handlers + vim.lsp.with nữa: deprecated ở nvim 0.11+.
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
        vim.lsp.codelens.enable(true, { bufnr = args.buf })
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
    end,
  })
end

--- LSP keymaps (diagnostics copy, inlay hints)
function M.setup_keymaps()
  local function fmt_diagnostic(d, bufnr)
    local fname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":.")
    local sev = vim.diagnostic.severity[d.severity] or "?"
    local src = d.source and (" " .. d.source) or ""
    local code = d.code and (" (" .. d.code .. ")") or ""
    return string.format("%s:%d:%d [%s]%s%s %s",
      fname, d.lnum + 1, d.col + 1, sev, src, code,
      d.message:gsub("%s+", " "))
  end

  local function copy_diag(lines, label)
    if not lines or #lines == 0 then
      vim.notify("No diagnostics", vim.log.levels.INFO)
      return
    end
    local text = table.concat(lines, "\n")
    vim.fn.setreg("+", text)
    vim.fn.setreg('"', text)
    vim.notify("Copied " .. label, vim.log.levels.INFO, { title = "Diagnostics" })
  end

  vim.keymap.set("n", "<leader>ld", function()
    vim.diagnostic.open_float(nil, { focus = true, scope = "line" })
  end, { desc = "Diagnostics: Detail" })

  vim.keymap.set("n", "<leader>ly", function()
    local buf = vim.api.nvim_get_current_buf()
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    local diags = vim.diagnostic.get(buf, { lnum = line })
    copy_diag(vim.tbl_map(function(d) return fmt_diagnostic(d, buf) end, diags), "line diagnostics")
  end, { desc = "Diagnostics: Copy line" })

  vim.keymap.set("n", "<leader>lY", function()
    local buf = vim.api.nvim_get_current_buf()
    local diags = vim.diagnostic.get(buf)
    table.sort(diags, function(a, b)
      return a.lnum == b.lnum and a.col < b.col or a.lnum < b.lnum
    end)
    copy_diag(vim.tbl_map(function(d) return fmt_diagnostic(d, buf) end, diags), "buffer diagnostics")
  end, { desc = "Diagnostics: Copy buffer" })

  vim.keymap.set("n", ";h", function()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
  end, { desc = "LSP: Toggle inlay hints" })
end

return M
