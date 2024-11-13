local util = require("nitpick.util")
local M = {}

---@param opts table
function M.setup(opts)
  M.linter_by_ft = opts.linter_by_ft

  M.setup_autocommands()
end

--- Function to try lint current buffer
---@param linter_by_ft table<{command:function, args:table, source:string, parser:function}>
function M.try_lint(linter_by_ft)
  if not linter_by_ft or type(linter_by_ft) ~= "table" then
    return nil
  end

  local linter_data = util.get_linter(linter_by_ft)
  M.run_linter(linter_data)
end

--- Function to setup autocommand
function M.setup_autocommands()
  local aug = vim.api.nvim_create_augroup("nitpick", { clear = true })

  -- Lint after saving the file
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*",
    group = aug,
    callback = function()
      M.try_lint(M.linter_by_ft)
    end
  })

  -- Lint when the lsp is attached
  vim.api.nvim_create_autocmd("LspAttach", {
    pattern = "*",
    group = aug,
    callback = function()
      M.try_lint(M.linter_by_ft)
    end
  })
end

--- Function to run the linter
---@private
---@param linter_info table
function M.run_linter(linter_info)
  local namespace = vim.api.nvim_create_namespace("nitpick")

  local uv = vim.uv
  local bufnr = vim.api.nvim_get_current_buf()
  local stdin = uv.new_pipe()
  local stdout = uv.new_pipe()
  local stderr = uv.new_pipe()

  if not linter_info then
    return nil
  end

  local command = linter_info.command()
  local args = vim.tbl_map(function(x)
    if type(x) == "function" then
      return x()
    else
      return x
    end
  end, linter_info.args)
  local source = linter_info.source

  local handle

  -- Callback function for uv.spawn
  local function on_spawn_exit()
    stdout:read_stop()
    stderr:read_stop()
    stdout:close()
    stderr:close()
    handle:close()
  end

  handle = uv.spawn(command, { args = args, stdio = { stdin, stdout, stderr } },
    on_spawn_exit
  )

  stdout:read_start(
    vim.schedule_wrap(
      function(err, data)
        if err then
          print("stdout err", err)
        end
        if data then
          local diagnostic = linter_info.parser(data, source)

          vim.diagnostic.set(namespace, bufnr, diagnostic)
        end
      end))

  stderr:read_start(function(err, data)
    if err then
      print("stderr err", err)
    end
    if data then
      print("stderr data", data)
    end
  end)
end

return M
