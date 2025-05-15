local M = {}

function prompt_notes(file_path)
  vim.ui.input({
    prompt = "Fleeting: ",
  }, function(input)
    if not input then
      return
    end

    local file, openerr = io.open(file_path, "a+")
    if openerr then
      print(openerr)
      return
    end
    if not file then
      return
    end
    local ts = os.date("%Y-%m-%d %H:%M:%S")
    local paragraph = "# " .. ts .. ":\n" .. input .. "\n\n"
    file:write(paragraph)
    file:flush()
    file:close()
  end)
end

function M.handle_fleeting_note()
  -- save the notes to the default ~/notes/fleeting folder
  local home_dir = vim.uv.os_homedir()
  local current_date = os.date("%Y-%m-%d")
  local notes_path = home_dir .. "/notes/fleeting/"
  local file_path = notes_path .. current_date .. ".md"

  if vim.uv.fs_stat(notes_path) then
    prompt_notes(file_path)
  else
    print("Unable to create note. Please create directory: " .. notes_path)
  end
end

function M.setup(opts) end

vim.api.nvim_create_user_command("FleetingNote", M.handle_fleeting_note, {})
vim.api.nvim_set_keymap("n", "<leader>5", ":FleetingNote<CR>", { noremap = true, silent = true })

return M
