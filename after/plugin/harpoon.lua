local harpoon = require("harpoon")

harpoon:setup({
    menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
    }
})

vim.keymap.set('n', '<leader>hm', function() harpoon:list():add() end)
vim.keymap.set('n', '<leader>hu', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
    end

    require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
            results = file_paths,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
    }):find()
end

vim.keymap.set("n", "<leader>ht", function() toggle_telescope(harpoon:list()) end,
    { desc = "Open harpoon window" })
