-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore
if true then
  return {
    {
      "andythigpen/nvim-coverage",
      version = "*",
      config = function()
        require("coverage").setup({
          auto_reload = true,
        })
      end,
    },
    {
      "catppuccin/nvim",
      name = "catppuccin"
    },
    {
      "ionide/Ionide-vim",
      config = function()
        vim.g['fsharp#fsi_keymap_send'] = '<leader>ps'
        vim.g['fsharp#fsi_keymap_toggle'] = '<leader>pt'
      end,
    },
    {
      "folke/noice.nvim",
      opts = {
        routes = {
          {
            -- this is needed to filter out excessive lsp progress messages from Ionide(F#)
            -- we just check if the message contains .fs extension and skip it
            filter = {
              event = "lsp",
              kind = "progress",
              find = ".*.fs.*",
            },
            opts = { skip = true },
          },
        },
      }
    },
    {
      "nvim-mini/mini.indentscope",
      opts = {
        draw = { animation = require("mini.indentscope").gen_animation.none() },
      }
    },
    {
      "akinsho/toggleterm.nvim",
      config = true,
      cmd = "ToggleTerm",
      keys = {
        { "<leader>j", "<cmd>ToggleTerm<cr>", desc = "Toggle floating terminal" }
      },
      opts = {
        open_mapping = [[<F4>]],
        direction = "float",
        shade_filetypes = {},
        hide_numbers = true,
        insert_mappings = true,
        terminal_mappings = true,
        start_in_insert = true,
        close_on_exit = true,
      },
    },
    {
      "seblyng/roslyn.nvim",
      ---@module 'roslyn.config'
      ---@type RoslynNvimConfig
      opts = {
        -- your configuration comes here; leave empty for default settings
      },
    },
    {
      "mason-org/mason.nvim",
      lazy = true,
      config = function()
        require('mason').setup({
          registries = {
            'github:Crashdummyy/mason-registry',
            'github:mason-org/mason-registry'
          }
        })
      end
    },
    {
      "LazyVim/LazyVim",
      opts = {
        colorscheme = "rose-pine-moon",
      },
    },
    {
      "rose-pine/neovim",
      name = "rose-pine",
    },
  }
end
