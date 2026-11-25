-- Treesitter (nvim-treesitter `main`): parsers and queries. Highlighting itself is built into
-- Neovim; this starts it for every filetype that has a parser and installs missing parsers on
-- first use. Building parsers needs the `tree-sitter` CLI and a C compiler (dotfiles base tools).
local M = {}
local ts = require("nvim-treesitter")

-- Installed up front; everything else is installed when a file of that type is first opened.
M.installing = ts.install({
  "bash", "css", "diff", "dockerfile", "gitcommit", "gitignore", "html", "java", "javascript",
  "jsdoc", "json", "kotlin", "lua", "luadoc", "markdown", "markdown_inline", "python", "query",
  "regex", "sql", "toml", "tsx", "typescript", "vim", "vimdoc", "yaml",
})

vim.treesitter.language.register("bash", "zsh")

local available -- parsers nvim-treesitter knows how to install, looked up once
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("trinne.treesitter", { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    if not lang then
      return
    end
    if pcall(vim.treesitter.start, ev.buf, lang) then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      return
    end
    available = available or ts.get_available()
    if vim.tbl_contains(available, lang) then
      ts.install(lang):await(function()
        if vim.api.nvim_buf_is_valid(ev.buf) and pcall(vim.treesitter.start, ev.buf, lang) then
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end)
    end
  end,
})

-- Text objects. Visual `an` / `in` (built in) grow and shrink the selection by syntax node.
require("nvim-treesitter-textobjects").setup({
  select = { lookahead = true },
  move = { set_jumps = true },
})

local select = require("nvim-treesitter-textobjects.select")
for keys, obj in pairs({
  ["a="] = "assignment.outer", ["i="] = "assignment.inner",
  ["l="] = "assignment.lhs", ["r="] = "assignment.rhs",
  ["aa"] = "parameter.outer", ["ia"] = "parameter.inner",
  ["ai"] = "conditional.outer", ["ii"] = "conditional.inner",
  ["al"] = "loop.outer", ["il"] = "loop.inner",
  ["af"] = "call.outer", ["if"] = "call.inner",
  ["am"] = "function.outer", ["im"] = "function.inner",
  ["ac"] = "class.outer", ["ic"] = "class.inner",
}) do
  vim.keymap.set({ "x", "o" }, keys, function()
    select.select_textobject("@" .. obj, "textobjects")
  end, { desc = obj:gsub("%.", " ") })
end

local swap = require("nvim-treesitter-textobjects.swap")
for suffix, obj in pairs({ a = "parameter.inner", m = "function.outer" }) do
  vim.keymap.set("n", "<leader>n" .. suffix, function()
    swap.swap_next("@" .. obj)
  end, { desc = "Swap " .. obj:gsub("%..*", "") .. " with next" })
  vim.keymap.set("n", "<leader>p" .. suffix, function()
    swap.swap_previous("@" .. obj)
  end, { desc = "Swap " .. obj:gsub("%..*", "") .. " with previous" })
end

-- ]m next function start, ]M next function end, [m / [M previous; same for f(call), c(lass),
-- i(f) and l(oop). Repeat with ; and , (also f/F/t/T).
local move = require("nvim-treesitter-textobjects.move")
for key, obj in pairs({ f = "call", m = "function", c = "class", i = "conditional", l = "loop" }) do
  local q = "@" .. obj .. ".outer"
  local function m(lhs, fn, desc)
    vim.keymap.set({ "n", "x", "o" }, lhs, function()
      move[fn](q, "textobjects")
    end, { desc = desc .. " " .. obj })
  end
  m("]" .. key, "goto_next_start", "Next")
  m("]" .. key:upper(), "goto_next_end", "Next end of")
  m("[" .. key, "goto_previous_start", "Previous")
  m("[" .. key:upper(), "goto_previous_end", "Previous end of")
end

local repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
vim.keymap.set({ "n", "x", "o" }, ";", repeat_move.repeat_last_move)
vim.keymap.set({ "n", "x", "o" }, ",", repeat_move.repeat_last_move_opposite)
vim.keymap.set({ "n", "x", "o" }, "f", repeat_move.builtin_f_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "F", repeat_move.builtin_F_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "t", repeat_move.builtin_t_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "T", repeat_move.builtin_T_expr, { expr = true })

require("nvim-ts-autotag").setup()

return M
