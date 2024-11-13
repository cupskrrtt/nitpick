local M = {}

local namespace = vim.api.nvim_create_namespace("nitpick_linter")

--Search available linter based on user input
---@param linter_by_ft table
function M.get_available_linter(linter_by_ft)
  local filetype = vim.bo.filetype

  if not linter_by_ft or not linter_by_ft[filetype] then
    return nil
  end

  for _, linter in pairs(linter_by_ft[filetype]) do
    local ok, data = pcall(require, "nitpick.linters." .. linter)
    if ok then
      if data.command() == 0 then
        goto continue
      else
        return M.get_linter_data(data)
      end
      ::continue::
    end
  end
end

--Get the linter data based on the given input
function M.get_linter_data(linter_data)
  return vim.tbl_map(function(data)
    if type(data) == "function" then
      return data()
    elseif type(data) == "table" then
      return vim.tbl_map(function(x)
        if type(x) == "function" then
          return x()
        else
          return x
        end
      end, data)
    else
      return data
    end
  end, linter_data)
end

--Run the linter
function M.run_linter(linter_data)
  local uv = vim.uv

  if not linter_data then
    return nil
  end

  --Get the current buffer and file path
  local bufnr = vim.api.nvim_get_current_buf()

  --Command for the linter (for now it's just eslint)
  local command = linter_data.command
  local args = linter_data.args
  local source = linter_data.source

  --Continue this parsing in asynchronous
  local stdin = uv.new_pipe()
  local stdout = uv.new_pipe()
  local stderr = uv.new_pipe()

  local handle

  local function on_spawn_exit(code, signal)
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
          local diagnostics_table = vim.json.decode(data)

          if not diagnostics_table or type(diagnostics_table) ~= "table" then
            print("Diagnostic table invalid")
          end

          for _, file_result in ipairs(diagnostics_table) do
            local diagnostics = {}


            for _, message in ipairs(file_result.messages) do
              table.insert(diagnostics, {
                lnum = (message.line or 1) - 1,
                col = (message.column or 1) - 1,
                message = message.message,
                severity = message.severity == 2 and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
                source = source,
              })
            end

            -- Set diagnostics for the buffer and namespace
            vim.diagnostic.set(namespace, bufnr, diagnostics)
          end
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
