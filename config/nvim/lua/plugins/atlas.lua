-- nvim-atlas: sidebar over claude-status/git-review/gh for reviewing and
-- driving AI coding sessions across repos and worktrees. In active local
-- development at ~/projects/nvim-atlas; `dir` points there directly so
-- changes show up on the next `:Lazy reload nvim-atlas` without a commit.

return {
  {
    "nvim-atlas",
    dir = vim.fn.expand("~/projects/nvim-atlas"),
    dependencies = { "sindrets/diffview.nvim", "akinsho/toggleterm.nvim" },
    cmd = { "AtlasToggle", "AtlasAnnotate" },
    keys = {
      { "<leader>ae", "<cmd>AtlasToggle<cr>", desc = "Atlas: toggle sidebar" },
      { "<leader>aa", "<cmd>AtlasAnnotate<cr>", mode = "n", desc = "Atlas: add a note on this line" },
      { "<leader>aa", ":AtlasAnnotate<cr>", mode = "x", desc = "Atlas: add a note on the selected lines" },
    },
    config = function()
      -- Neovim's launch PATH doesn't reliably include ~/.dotfiles/bin
      -- (where claude-status/git-review live) the way an interactive
      -- shell that's sourced .zshrc does, so point atlas at it directly.
      require("atlas").setup({ bin_dir = "~/.dotfiles/bin" })
    end,
  },
}
