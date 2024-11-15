local util = require("nitpick.util")
local M = {}

---@param opts table
function M.setup(opts)
  M.linter_by_ft = opts.linter_by_ft

  local auto_lint = opts.auto_lint

  if auto_lint == nil or auto_lint == true then
    M.setup_autocommands()
  end
end

vim.api.nvim_create_user_command("NitpickQuickFix", function()
  M.add_to_quickfix()
end, { bang = false })

vim.api.nvim_create_user_command("NitpickLint", function()
  M.try_lint(M.linter_by_ft)
end, { bang = false })


--- Add all diagnostic to quick fix list
---@private
function M.add_to_quickfix()
  local diagnostic = vim.diagnostic.get(vim.api.nvim_get_current_buf())
  local qflist = vim.diagnostic.toqflist(diagnostic)
  vim.diagnostic.setqflist(qflist)
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
---@param linter_info table|nil
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
  local stream = linter_info.stream


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

  local stdout_output = ""
  local stderr_output = ""

  if stream == "stderr" then
    stderr:read_start(
      vim.schedule_wrap(
        function(err, data)
          if err then
            print("stderr err", err)
          end
          if data then
            stderr_output = stderr_output .. data
            local diagnostic = linter_info.parser(stderr_output, source)
            if not diagnostic then
              return
            end
            vim.diagnostic.set(namespace, bufnr, diagnostic)
          end
        end))
  else
    stdout:read_start(
      vim.schedule_wrap(
        function(err, data)
          if err then
            print("stdout err", err)
          end
          if data then
            stdout_output = stdout_output .. data

            local diagnostic = linter_info.parser(stdout_output, source)
            if not diagnostic then
              return
            end
            vim.diagnostic.set(namespace, bufnr, diagnostic)
          end
        end))
  end
end

return M
