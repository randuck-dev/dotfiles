
vim.wo.number = true
vim.wo.rnu = true

vim.o.undofile = true
vim.o.mouse = 'a'
vim.o.scrolloff = 8
vim.o.colorcolumn = "80"
vim.o.termguicolors = true

vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.expandtab = true

vim.o.smartindent = true


vim.opt.splitright = true
vim.opt.splitbelow = true

-- vim.opt.updatetime = 250
--
-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

vim.g.have_nerd_font = true


-- Synchronize clipboard between OS and nvim
vim.opt.clipboard = 'unnamedplus'

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }


