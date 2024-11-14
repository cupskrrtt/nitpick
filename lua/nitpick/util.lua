local M = {}

--- Safely load linter
---@param linter string
---@return table
function M.load_linter(linter)
  local ok, linter_info = pcall(require, "nitpick.linters." .. linter)
  if not ok then
    return {}
  end

  return linter_info
end

local function find_root_dir(root_pattern)
  -- Get the current file's directory
  local current_dir = vim.fn.expand("%:p:h")

  -- Search for a directory containing any of the exact patterns
  for _, pattern in ipairs(root_pattern) do
    local root = vim.fs.find(pattern, { upward = true, path = current_dir })
    if #root > 0 then
      return vim.fs.dirname(root[1])
    end
  end

  return nil
end

--- Search the config file for linter inside the /linters folder
---@param linter_by_ft table
---@return table|nil
function M.get_linter(linter_by_ft)
  local filetype = vim.bo.filetype

  if not linter_by_ft or not linter_by_ft[filetype] then
    return nil
  end

  for _, linter in pairs(linter_by_ft[filetype]) do
    local linter_config = M.load_linter(linter)
    local root_dir = find_root_dir(linter_config.root_pattern)
    if root_dir then
      if linter_config.command() ~= nil then
        return linter_config
      end
    end

    -- local root_dir = find_root_dir(linter_config.root_pattern)
    -- if linter_config and linter_config.command() ~= 0 then
    --   return linter_config
    -- end
  end

  return nil
end

return M
