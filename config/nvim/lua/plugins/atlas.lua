-- nvim-atlas (github.com/randuck-dev/nvim-atlas): sidebar over
-- claude-status/git-review/gh for reviewing and driving AI coding sessions
-- across repos and worktrees.
--
-- `dev = true`: lazy uses the local checkout at ~/projects/nvim-atlas when
-- it exists (see `dev` in config/lazy.lua), so changes there show up on
-- the next `:Lazy reload nvim-atlas` without a commit; machines without
-- the checkout install it from GitHub.

return {
  {
    "randuck-dev/nvim-atlas",
    dev = true,
    dependencies = { "sindrets/diffview.nvim" },
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
