local binary_name = "eslint_d"

---@type nitpick.FileLinterConfig
return {
  command = function()
    local local_binary = vim.fn.fnamemodify("./node_modules/.bin/" .. binary_name, ":p")
    if local_binary then
      if vim.uv.fs_stat(local_binary) then
        return local_binary
      end
    end

    if vim.fn.executable(binary_name) == 1 then
      return binary_name
    end
  end,
  args = {
    "--format",
    "json",
    function()
      return vim.api.nvim_buf_get_name(0)
    end
  },
  source = binary_name,
  stream = "stdout",
  parser = function(data, source)
    -- For eslint_d the data is returned in json format
    -- The data can be easily processed by the following code
    --
    print(data)

    local ok, diag = pcall(vim.json.decode, data)
    if ok then
      if not diag or type(diag) ~= "table" then
        return nil
      end

      local diagnostics = {}
      for _, lint_output in ipairs(diag) do
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
  end,
  root_pattern = {
    ".eslintrc.js",
    ".eslintrc.ts",
    ".eslintrc.json",
    ".eslintrc.yml",
    ".eslintrc.yaml",
    "eslint.config.js",
    "eslint.config.json",
    "eslint.config.ts"
  },
}
