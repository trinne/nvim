-- Color theme shared with the dotfiles (github.com/trinne/dotfiles).
--
-- The dotfiles write the active theme name to ~/.config/dotfiles/theme (`theme set <name>`).
-- This module maps that name to a colorscheme, applies it on startup and follows changes
-- live, so running nvim instances switch together with the terminal, tmux etc.
--
-- Theme names match home/.chezmoidata/themes.toml in the dotfiles. Without the dotfiles,
-- $COLOR_THEME or the default below is used.

local M = {}

M.default = "tokyonight-storm"

-- theme name -> colorscheme (the plugins are defined in plugins/theme.lua)
M.colorschemes = {
  ["tokyonight-storm"] = "tokyonight-storm",
  ["nord"] = "nord",
  ["catppuccin-mocha"] = "catppuccin-mocha",
}

local dir = vim.fs.joinpath(vim.env.XDG_CONFIG_HOME or vim.fs.joinpath(vim.env.HOME, ".config"), "dotfiles")
local file = vim.fs.joinpath(dir, "theme")

--- The active theme name: dotfiles file, then $COLOR_THEME, then the default.
function M.current()
  local f = io.open(file, "r")
  if f then
    local name = vim.trim(f:read("*a") or "")
    f:close()
    if name ~= "" then
      return name
    end
  end
  return vim.env.COLOR_THEME or M.default
end

--- Apply a theme by name (defaults to the active one).
function M.apply(name)
  name = name or M.current()
  local scheme = M.colorschemes[name]
  if not scheme then
    vim.notify(("Unknown theme '%s', using %s"):format(name, M.default), vim.log.levels.WARN)
    name, scheme = M.default, M.colorschemes[M.default]
  end
  if vim.g.colors_name ~= scheme then
    vim.cmd.colorscheme(scheme)
  end
  M.active = name
end

--- Re-apply when the dotfiles switch themes. Watches the directory, because chezmoi
--- replaces the file instead of writing it in place.
function M.watch()
  if M.watcher or not vim.uv.fs_stat(dir) then
    return
  end
  M.watcher = vim.uv.new_fs_event()
  M.watcher:start(dir, {}, function(err, filename)
    if err or filename ~= "theme" then
      return
    end
    vim.schedule(function()
      if M.current() ~= M.active then
        M.apply()
      end
    end)
  end)
end

function M.setup()
  M.apply()
  M.watch()
end

return M
