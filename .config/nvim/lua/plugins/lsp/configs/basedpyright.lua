-- Basedpyright (Python) Configuration
return {
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local nested_root = vim.fs.root(fname, { ".venv", "pyproject.toml", ".git" })
    on_dir(nested_root or vim.fn.getcwd())
  end,

  on_init = function(client)
    local root_dir = vim.fn.getcwd()
    if client.workspace_folders and client.workspace_folders[1] then
      root_dir = client.workspace_folders[1].name
    end
    local venv_win = root_dir .. "/.venv/Scripts/python.exe"
    local venv_unix = root_dir .. "/.venv/bin/python"
    local python_path = nil
    if vim.fn.executable(venv_win) == 1 then
      python_path = venv_win
    elseif vim.fn.executable(venv_unix) == 1 then
      python_path = venv_unix
    end

    if python_path then
      if client.config.settings and client.config.settings.basedpyright then
        client.config.settings.basedpyright.pythonPath = python_path
      end
    end
    if client.config.settings and client.config.settings.basedpyright and client.config.settings.basedpyright.analysis then
      client.config.settings.basedpyright.analysis.extraPaths = { root_dir }
    end
    client.rpc.notify("workspace/didChangeConfiguration", { settings = client.config.settings })

    return true
  end,

  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "basic", -- "off", "basic", "standard", "strict"
        autoImportCompletions = true,
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly", -- crucial optimization for large projects
        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
          callArgumentNames = true,
        },
      },
    },
  },
}
