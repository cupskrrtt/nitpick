local binary_name = "biome"

---@type nitpick.FileLinterConfig
return {
  command = function()
    local local_binary = vim.fn.fnamemodify("./node_modules/.bin/" .. binary_name, ":p")
    return vim.uv.fs_stat(local_binary) and local_binary or vim.fn.executable(binary_name)
  end,
  args = {
    "lint",
    function()
      return vim.api.nvim_buf_get_name(0)
    end,
  },
  source = binary_name,
  parser = function()

  end

}
