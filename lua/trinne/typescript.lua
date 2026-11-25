-- Which TypeScript language server a buffer gets:
--   TypeScript 7+ in the project (native compiler)  → `tsc --lsp` from node_modules
--   older TypeScript, or none (plain JS)            → vtsls
local M = {}

local cache = {}

--- Major version of the project's own TypeScript (node_modules/typescript), or nil
function M.project_major(bufnr)
  local root = vim.fs.root(bufnr, "node_modules")
  if not root then
    return nil
  end
  if cache[root] == nil then
    local ok, pkg = pcall(function()
      local f = assert(io.open(vim.fs.joinpath(root, "node_modules", "typescript", "package.json")))
      local data = vim.json.decode(f:read("*a"))
      f:close()
      return data
    end)
    local v = ok and vim.version.parse(pkg.version or "")
    cache[root] = v and v.major or false
  end
  return cache[root] or nil
end

function M.native(bufnr)
  return (M.project_major(bufnr) or 0) >= 7
end

--- nvim-lspconfig's root_dir for `name`, applied only where M.native(bufnr) == want_native.
--- (Inside after/lsp/<name>.lua, vim.lsp.config[name] would recurse, so load the file itself.)
function M.root_dir(name, want_native)
  local file = vim.api.nvim_get_runtime_file("lsp/" .. name .. ".lua", false)[1]
  local default = dofile(file).root_dir
  return function(bufnr, on_dir)
    if M.native(bufnr) == want_native then
      default(bufnr, on_dir)
    end
  end
end

return M
