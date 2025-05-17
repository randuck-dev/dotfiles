local set = vim.keymap.set

require("config.lazy")

function hyperset(mode, binding, cmd)
  set(mode, "<F18>" .. binding, cmd)
end

set("t", "<esc><esc>", "<c-\\><c-n>")

set("n", "<C-t>", "<cmd>!tmux neww ~/.dotfiles/tmux-sessionizer.sh<CR>", { desc = "Run sessionizer" })

set("n", "<leader><leader>x", "<cmd>source %<CR>", {
  desc = "Execute the current file",
  callback = function()
    local currentFile = vim.api.nvim_buf_get_name(0)
    print("Sourced: " .. currentFile)
  end,
})
