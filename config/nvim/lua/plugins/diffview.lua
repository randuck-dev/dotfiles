-- diffview.nvim: side-by-side review of a branch.
--
-- `git review` (bin/git-review) starts Neovim with g:review_mode set and
-- runs :DiffviewOpen <merge base>, which compares the branch's start
-- point with the files as they are now. In that mode the file list gets
-- focus and q quits Neovim; otherwise q just closes diffview.

local function quit()
  if vim.g.review_mode then
    -- Don't let persistence.nvim save this layout as the folder's session.
    pcall(function()
      require("persistence").stop()
    end)
    vim.cmd("qa!")
  else
    vim.cmd("DiffviewClose")
  end
end

return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview (working tree)" },
      { "<leader>gV", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview file history" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = { layout = "diff2_horizontal" }, -- side by side; g<C-x> cycles layouts
      },
      file_panel = {
        listing_style = "tree",
        win_config = { position = "left", width = 34 },
      },
      hooks = {
        view_opened = function()
          if vim.g.review_mode then
            require("diffview.actions").focus_files()
          end
        end,
      },
      keymaps = {
        view = { { "n", "q", quit, { desc = "Close review" } } },
        file_panel = { { "n", "q", quit, { desc = "Close review" } } },
        file_history_panel = { { "n", "q", quit, { desc = "Close review" } } },
      },
    },
  },
}
