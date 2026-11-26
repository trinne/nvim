-- Language servers, formatters and debug adapters, installed with mason.
--
-- A tool is installed only when its runtime is available (`needs`): on a host without Node
-- nothing npm-based is installed, and in a devbox container the project's mise.toml brings
-- the runtime. Servers listed in `lsp` are enabled with vim.lsp.enable() once installed.
-- Project-local binaries (node_modules/.bin) win over mason's for biome, oxlint, oxfmt,
-- eslint and prettier, so the editor uses the project's pinned versions.
local M = {}

M.tools = {
  -- always (standalone binaries)
  { pkg = "lua-language-server", lsp = { "lua_ls" } },
  { pkg = "stylua" },
  { pkg = "shellcheck" }, -- used by bashls
  { pkg = "shfmt" },
  { pkg = "taplo", lsp = { "taplo" } },
  { pkg = "biome", lsp = { "biome" }, needs = "node" }, -- fallback; attaches only with a biome.json
  -- node
  { pkg = "vtsls", lsp = { "vtsls", "tsc" }, needs = "node" }, -- tsc: TypeScript 7+ projects, see lua/trinne/typescript.lua
  { pkg = "eslint-lsp", lsp = { "eslint" }, needs = "node" }, -- attaches only with an eslint config
  { pkg = "html-lsp", lsp = { "html" }, needs = "node" },
  { pkg = "css-lsp", lsp = { "cssls" }, needs = "node" },
  { pkg = "json-lsp", lsp = { "jsonls" }, needs = "node" },
  { pkg = "tailwindcss-language-server", lsp = { "tailwindcss" }, needs = "node" },
  { pkg = "oxlint", lsp = { "oxlint" }, needs = "node" }, -- only with an oxlint config
  { pkg = "bash-language-server", lsp = { "bashls" }, needs = "node" },
  { pkg = "yaml-language-server", lsp = { "yamlls" }, needs = "node" },
  { pkg = "dockerfile-language-server", lsp = { "dockerls" }, needs = "node" },
  { pkg = "prettierd", needs = "node" },
  { pkg = "js-debug-adapter", needs = "node" },
  -- python
  { pkg = "basedpyright", lsp = { "basedpyright" }, needs = "python3" },
  { pkg = "ruff", lsp = { "ruff" }, needs = "python3" },
  -- java / kotlin (jdtls is started by nvim-jdtls, see plugins/java.lua)
  { pkg = "jdtls", needs = "java" },
  { pkg = "java-debug-adapter", needs = "java" },
  { pkg = "java-test", needs = "java" },
  { pkg = "kotlin-lsp", lsp = { "kotlin_lsp" }, needs = "java" },
  { pkg = "kotlin-debug-adapter", needs = "java" },
  { pkg = "ktlint", needs = "java" },
  -- clojure
  { pkg = "clojure-lsp", lsp = { "clojure_lsp" }, needs = "clojure" },
}

local function wanted(tool)
  return not tool.needs or vim.fn.executable(tool.needs) == 1
end

--- Calls on_missing(tool, pkg) for every wanted tool that is not installed yet and
--- on_installed(tool) for the rest, then done(). Runs after the mason registry is up to date.
local function each_tool(on_installed, on_missing, done)
  local registry = require("mason-registry")
  registry.refresh(vim.schedule_wrap(function()
    for _, tool in ipairs(M.tools) do
      if wanted(tool) then
        local ok, pkg = pcall(registry.get_package, tool.pkg)
        if not ok then
          vim.notify("mason: unknown package " .. tool.pkg, vim.log.levels.WARN)
        elseif pkg:is_installed() then
          on_installed(tool)
        elseif not pkg:is_installing() then
          on_missing(tool, pkg)
        end
      end
    end
    if done then
      done()
    end
  end))
end

local function enable(tool)
  if tool.lsp then
    vim.lsp.enable(tool.lsp)
  end
end

function M.setup()
  require("mason").setup()
  local registry = require("mason-registry")
  -- Enable what is installed right away (no registry refresh needed), so servers attach to
  -- the files opened at startup; install the rest in the background.
  for _, tool in ipairs(M.tools) do
    if wanted(tool) and registry.is_installed(tool.pkg) then
      enable(tool)
    end
  end
  each_tool(function() end, function(tool, pkg)
    pkg:install(
      {},
      vim.schedule_wrap(function(success)
        if success then
          enable(tool)
        else
          vim.notify("mason: installing " .. tool.pkg .. " failed, see :Mason", vim.log.levels.WARN)
        end
      end)
    )
  end)
end

--- Install all wanted tools and treesitter parsers, and wait. For scripts and CI:
---   nvim --headless "+lua require('trinne.tools').sync()" +qa
function M.sync(timeout)
  timeout = timeout or 900000
  local registry = require("mason-registry")
  local busy = {} -- packages installed by this call or already installing (started by setup)
  local listed = false
  each_tool(function() end, function(tool, pkg)
    pkg:install({}, function(success, err)
      if not success then
        io.stderr:write(("mason: %s failed: %s\n"):format(tool.pkg, vim.inspect(err)))
      end
    end)
  end, function()
    for _, tool in ipairs(M.tools) do
      if wanted(tool) and registry.has_package(tool.pkg) then
        busy[#busy + 1] = registry.get_package(tool.pkg)
      end
    end
    listed = true
  end)
  vim.wait(timeout, function()
    if not listed then
      return false
    end
    for _, pkg in ipairs(busy) do
      if pkg:is_installing() then
        return false
      end
    end
    return true
  end, 200)
  require("trinne.plugins.treesitter").installing:wait(timeout)
end

return M
