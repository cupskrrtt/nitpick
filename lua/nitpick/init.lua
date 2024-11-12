local M = {}

---@param opts table
function M.setup(opts)
  M.linter_by_ft = opts.linter_by_ft

  M.setup_autocommands()
end

local function find_executable(linter)
  local local_path = vim.fn.getcwd() .. "/node_modules/.bin/" .. linter
  if vim.fn.executable(local_path) == 1 then
    return local_path
  end

  local global_path = linter
  if vim.fn.executable(global_path) == 1 then
    return global_path
  end

  return nil
end

local function run_linter(bufnr)
  local eslint_path = find_executable("eslint")
  if not eslint_path then
    vim.notify("ESLint not found, please install it.", vim.log.levels.WARN)
    return
  end

  local cmd = {
    eslint_path,
    "--format",
    "json",
    "--stdin",
    "--stdin-filename",
    vim.api.nvim_buf_get_name(bufnr),
  }

  local result = vim.fn.system(cmd, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  if vim.v.shell_error ~= 0 then
    local diagnostics = vim.fn.json_decode(result)
    local linter_diagnostics = {}
    for _, diagnostic in ipairs(diagnostics) do
      table.insert(linter_diagnostics, {
        bufnr = bufnr,
        lnum = diagnostic.line,
        col = diagnostic.column,
        text = diagnostic.message,
        severity = diagnostic.severity == 2 and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
        source = "ESLint",
      })
    end
    vim.diagnostic.setloclist({ items = linter_diagnostics })
    vim.notify("ESLint found " .. #linter_diagnostics .. " issues.", vim.log.levels.WARN)
  else
    vim.notify("No ESLint issues found.", vim.log.levels.INFO)
  end
end

---@private
function M.setup_autocommands()
  vim.api.nvim_create_augroup("nitpick", { clear = true })

  -- Lint on buffer leave
  vim.api.nvim_create_autocmd("BufLeave", {
    pattern = "*", -- Apply to all file types
    group = "nitpick",
    callback = function()
      run_linter(vim.api.nvim_get_current_buf())
    end
  })

  -- Lint after saving the file
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*", -- Apply to all file types
    group = "nitpick",
    callback = function()
      run_linter(vim.api.nvim_get_current_buf())
    end
  })

  -- Lint on entering the buffer
  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*", -- Apply to all file types
    group = "nitpick",
    callback = function()
      run_linter(vim.api.nvim_get_current_buf())
    end
  })
end

return M
