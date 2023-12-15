require("randuck")

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end

vim.opt.rtp:prepend(lazypath)


require('lazy').setup({
	{ 
		'nvim-telescope/telescope.nvim', tag = '0.1.4',
		dependencies = {'nvim-lua/plenary.nvim'}
	},
	'navarasu/onedark.nvim',
	'nvim-lualine/lualine.nvim',
	{
		"nvim-treesitter/nvim-treesitter", 
		build = ":TSUpdate",
		config = function ()
			local configs = require("nvim-treesitter.configs")
			configs.setup({
				ensure_installed = { "go", "lua", "vim"},
				sync_install = false,
				higlight = {enable = true},
				indent = {enable = true},
			})
		end
	},

	{'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
	{'williamboman/mason.nvim'},
	{'williamboman/mason-lspconfig.nvim'},
	{'neovim/nvim-lspconfig'},
	{'hrsh7th/cmp-nvim-lsp'},
	{'hrsh7th/nvim-cmp'},
	{'L3MON4D3/LuaSnip'},
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 }
})


vim.cmd.colorscheme 'onedark'

local telescope = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', telescope.find_files, {})
vim.keymap.set('n', '<C-p>', telescope.git_files, {})

-- If fzf is installed, we ensure that telescope is going to use it
pcall(require('telescope').load_extension, 'fzf')


require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = 'onedark',
    component_separators = '|',
    section_separators = '',
  },
}

local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

-- see :help lsp-zero-guide:integrate-with-mason-nvim
-- to learn how to use mason.nvim with lsp-zero
require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {"lua_ls", "gopls", "bashls"},
  handlers = {
    lsp_zero.default_setup,
    lua_ls = function()
      local lua_opts = lsp_zero.nvim_lua_ls()

      require('lspconfig').lua_ls.setup(lua_opts)
    end,
  }
})
