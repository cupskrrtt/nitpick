local binary_name = "eslint"
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
  source = binary_name
}
