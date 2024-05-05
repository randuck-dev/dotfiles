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
  ensure_installed = {"lua_ls", "marksman", "rust_analyzer", "pyright", "terraformls", "tflint"},
  handlers = {
    lsp_zero.default_setup,
    lua_ls = function()
      local lua_opts = lsp_zero.nvim_lua_ls()

      require('lspconfig').lua_ls.setup(lua_opts)
    end,

    terraformls = function()
        require('lspconfig').terraformls.setup({})
    end,

    tflint = function ()
        require('lspconfig').tflint.setup({})
    end

  }
})