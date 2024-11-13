local binary_name = "eslint"

---@type nitpick.FileLinterConfig
return {
  command = function()
    local local_binary = vim.fn.fnamemodify("./node_modules/.bin/" .. binary_name, ":p")
    return vim.uv.fs_stat(local_binary) and local_binary or vim.fn.executable(binary_name)
  end,
  args = {
    function()
      return vim.api.nvim_buf_get_name(0)
    end,
    "--format",
    "json"
  },
  source = binary_name,
  parser = function(data, source)
    -- For eslint the data is returned in json format
    -- The data can be easily processed by the following code

    local diagnostic_table = vim.json.decode(data)

    if not diagnostic_table or type(diagnostic_table) ~= "table" then
      return nil
    end

    local diagnostics = {}
    for _, lint_output in ipairs(diagnostic_table) do
      for _, message in ipairs(lint_output.messages) do
        table.insert(diagnostics, {
          lnum = (message.line or 1) - 1,
          col = (message.column or 1) - 1,
          message = message.message,
          severity = message.severity == 2 and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
          source = source,
        })
      end
    end
    return diagnostics
  end
}
