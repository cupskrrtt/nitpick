local util = require("nitpick.util")
local M = {}

---@param opts table
function M.setup(opts)
  M.linter_by_ft = opts.linter_by_ft

  M.setup_autocommands()
end

---@param linter_by_ft table
function M.try_lint(linter_by_ft)
  if not linter_by_ft or type(linter_by_ft) ~= "table" then
    return nil
  end

  --Get linter data
  local linter_data = util.get_available_linter(linter_by_ft)
  util.run_linter(linter_data)
end

---@private
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

return M
