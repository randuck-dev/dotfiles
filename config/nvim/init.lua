local set = vim.keymap.set

require("config.lazy")

function hyperset(mode, binding, cmd)
  set(mode, "<F18>" .. binding, cmd)
end

vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

set("n", "<leader><leader>x", "<cmd>source %<CR>", {
  desc = "Execute the current file",
  callback = function()
    local currentFile = vim.api.nvim_buf_get_name(0)
    print("Sourced: " .. currentFile)
  end,
})
