local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.colorcolumn = "120"
opt.cursorline = true
opt.scrolloff = 8
opt.wrap = false
opt.termguicolors = true
opt.winborder = "rounded" -- floating windows (hover, signature, diagnostics)
opt.splitright = true
opt.splitbelow = true

opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

opt.swapfile = false
opt.backup = false
opt.undofile = true -- kept in stdpath("state")/undo

opt.hlsearch = false
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

opt.isfname:append("@-@")
opt.updatetime = 250
opt.timeoutlen = 400 -- which-key pops up after this
opt.completeopt = { "menu", "menuone", "noselect", "popup" }
opt.confirm = true
