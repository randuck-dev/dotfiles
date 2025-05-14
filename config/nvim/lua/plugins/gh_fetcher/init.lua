local M = {}

local timer

function fetch_requested_prs()
  local result = vim.system({ "gh", 'search prs --state open "review-requested@me"' }, { text = true }):wait()
  local res = vim.split(result.stdout, "\n")
  local current_time = os.date("%Y-%m-%d %H:%M:%S")
  res[#res + 1] = "Last Fetched: " .. current_time
  return res
end

function M.open_window()
  local buf = vim.api.nvim_create_buf(false, true)
  local width = vim.o.columns
  local height = vim.o.lines

  local win_width = 60
  local win_height = 20

  -- Calculate the position for the upper right corner
  local row = 1
  local col = width - win_width - 1

  local opts = {
    relative = "editor",
    title = "GitHub PRs",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  }

  local window = vim.api.nvim_open_win(buf, true, opts)

  if timer then
    timer:stop()
    timer:close()
  end

  timer = vim.uv.new_timer()
  timer:start(
    0,
    10000,
    vim.schedule_wrap(function()
      local result = fetch_requested_prs()

      vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)
    end)
  )

  vim.api.nvim_create_autocmd({ "WinClosed" }, {
    buffer = buf,
    callback = function(ev)
      if timer then
        timer:stop()
        timer:close()
        timer = nil
      end
    end,
  })
end

vim.api.nvim_create_user_command("GhPrs", M.open_window, {})
vim.api.nvim_set_keymap("n", "<leader>gp", ":GhPrs<CR>", { noremap = true, silent = true })

return M
