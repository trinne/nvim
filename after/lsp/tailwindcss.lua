-- Only in projects that use Tailwind: a tailwind.config.* file, or tailwindcss in the nearest
-- package.json (Tailwind v4 needs no config file). nvim-lspconfig would also start it in any
-- git repository.
return {
  root_dir = function(bufnr, on_dir)
    local path = vim.api.nvim_buf_get_name(bufnr)
    local config = vim.fs.find(function(name)
      return name:match("^tailwind%.config%.[cm]?[jt]s$") ~= nil
    end, { path = path, upward = true })[1]
    if config then
      return on_dir(vim.fs.dirname(config))
    end
    local pkg = vim.fs.find("package.json", { path = path, upward = true })[1]
    local f = pkg and io.open(pkg)
    if f then
      local uses = f:read("*a"):find('"tailwindcss"', 1, true)
      f:close()
      if uses then
        on_dir(vim.fs.dirname(pkg))
      end
    end
  end,
}
