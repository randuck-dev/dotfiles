-- nvim-treesitter's install path runs `tree-sitter build`, whose
-- linker-generated ad-hoc signature doesn't satisfy this machine's
-- codesign page validation on first dlopen: SIGKILL, CODESIGNING:
-- Invalid Page, the moment a freshly-built parser gets loaded (e.g. the
-- very next time its filetype's buffer is opened). An explicit `codesign
-- --sign -` pass after the build fixes it. Watches the parser install
-- dir so every future `:TSInstall`/`:TSUpdate` stays fixed automatically,
-- rather than needing a manual re-sign each time.

local parser_dir = vim.fn.stdpath("data") .. "/site/parser"

local handle = vim.uv.new_fs_event()
if handle then
  handle:start(parser_dir, {}, function(err, filename)
    if err or not filename or not filename:match("%.so$") then
      return
    end
    -- Give the writer a moment to finish before signing.
    vim.defer_fn(function()
      vim.system({ "codesign", "--sign", "-", "--force", parser_dir .. "/" .. filename })
    end, 200)
  end)
end
