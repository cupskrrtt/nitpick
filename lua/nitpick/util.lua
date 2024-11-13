local M = {}

--- Safely load linter
---@param linter string
---@return table|nil
function M.load_linter(linter)
  local ok, linter_info = pcall(require, "nitpick.linters." .. linter)
  if not ok then
    return nil
  end

  return linter_info
end

--- Search the config file for linter inside the /linters folder
---@param linter_by_ft table
---@return table
function M.get_linter(linter_by_ft)
  local filetype = vim.bo.filetype

  if not linter_by_ft or not linter_by_ft[filetype] then
    return {}
  end

  for _, linter in pairs(linter_by_ft[filetype]) do
    local linter_config = M.load_linter(linter)
    if linter_config and linter_config.command() ~= 0 then
      return linter_config
    end
  end

  return {}
end

return M
