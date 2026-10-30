-- nvim-atlas (github.com/randuck-dev/nvim-atlas): sidebar over
-- claude-status/git-review/gh for reviewing and driving AI coding sessions
-- across repos and worktrees.
--
-- `dev = true`: lazy uses the local checkout at ~/projects/nvim-atlas when
-- it exists (see `dev` in config/lazy.lua), so changes there show up on
-- the next `:Lazy reload nvim-atlas` without a commit; machines without
-- the checkout install it from GitHub, and update it on every start (see
-- `init`), since lazy's update checker only checks.

return {
  {
    "randuck-dev/nvim-atlas",
    dev = true,
    dependencies = { "sindrets/diffview.nvim" },
    init = function()
      if vim.uv.fs_stat(vim.fn.expand("~/projects/nvim-atlas")) then
        return -- the local checkout is used as-is
      end
      -- In the background; the new version loads on the next start.
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        once = true,
        callback = function()
          require("lazy.manage").update({ plugins = { "nvim-atlas" }, show = false })
        end,
      })
    end,
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
