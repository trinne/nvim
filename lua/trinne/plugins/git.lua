-- Git: gitsigns for hunks in the buffer; lazygit (<leader>lg) and git pickers from snacks.
require("gitsigns").setup({
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
    local function lines()
      return { vim.fn.line("."), vim.fn.line("v") }
    end

    map("n", "]h", function()
      gs.nav_hunk("next")
    end, "Next hunk")
    map("n", "[h", function()
      gs.nav_hunk("prev")
    end, "Previous hunk")

    map("n", "<leader>hs", gs.stage_hunk, "Stage / unstage hunk")
    map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
    map("v", "<leader>hs", function()
      gs.stage_hunk(lines())
    end, "Stage / unstage lines")
    map("v", "<leader>hr", function()
      gs.reset_hunk(lines())
    end, "Reset lines")
    map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
    map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
    map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
    map("n", "<leader>hb", function()
      gs.blame_line({ full = true })
    end, "Blame line")
    map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle line blame")
    map("n", "<leader>hd", gs.diffthis, "Diff against index")
    map("n", "<leader>hD", function()
      gs.diffthis("~")
    end, "Diff against last commit")
    map({ "o", "x" }, "ih", gs.select_hunk, "Hunk")
  end,
})

local P = Snacks.picker
vim.keymap.set("n", "<leader>hl", P.git_log_file, { desc = "Log of this file" })
vim.keymap.set("n", "<leader>hc", P.git_status, { desc = "Changed files" })
