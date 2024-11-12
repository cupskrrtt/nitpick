local M = {}

---@param linter string
function M.from_node_modules(linter)
  return M.find_executable({ "node_modules/.bin/" .. linter }, linter)
end

---@param paths string[]
---@param linter string
function M.find_executable(paths, linter)
  for _, path in ipairs(paths) do
    print(vim.fs.normalize(path))
  end
end

return M
