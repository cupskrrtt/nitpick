local binary_name = "biome"

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
      print("Is Exe", vim.fn.executable(binary_name))
      return binary_name
    end
  end,
  args = {
    "lint",
    function()
      return vim.api.nvim_buf_get_name(0)
    end,
  },
  stream = "stderr",
  source = binary_name,
  parser = function(output, source)
    local diagnostics = {}

    -- Thanks to mfussenegger for the biome parser code :)

    -- The diagnostic details we need are spread in the first 3 lines of
    -- each error report.  These variables are declared out of the FOR
    -- loop because we need to carry their values to parse multiple lines.
    local fetch_message = false
    local lnum, col, code, message

    -- When a lnum:col:code line is detected fetch_message is set to true.
    -- While fetch_message is true we will search for the error message.
    -- When a error message is detected, we will create the diagnostic and
    -- set fetch_message to false to restart the process and get the next
    -- diagnostic.
    for _, line in ipairs(vim.fn.split(output, "\n")) do
      if fetch_message then
        _, _, message = string.find(line, "%s×(.+)")

        if message then
          message = (message):gsub("^%s+×%s*", "")

          table.insert(diagnostics, {
            source = source,
            lnum = tonumber(lnum) - 1,
            col = tonumber(col),
            message = message,
            code = code
          })

          fetch_message = false
        end
      else
        _, _, lnum, col, code = string.find(line, "[^:]+:(%d+):(%d+)%s([%a%/]+)")

        if lnum then
          fetch_message = true
        end
      end
    end

    return diagnostics
  end,
  root_pattern = {
    "biome.json"
  }

}
