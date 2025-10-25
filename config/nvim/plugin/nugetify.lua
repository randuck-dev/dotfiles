local M = {}

---@class Package
---@field id string
---@field requestedVersion string?
---@field resolvedVersion string

---@class VersionedPackage
---@field id string
---@field version string

--- @param namespace integer
--- @param bufnr integer
function M.show_version_details_hint(namespace, bufnr, details)
  vim.diagnostic.set(
    namespace,
    bufnr, -- buffer number (0 = current buffer)
    details,
    {
      underline = false,
    }
  )
end

--- @param text string
--- @return integer | nil
local function find_line_with_text(text)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for i, line in ipairs(lines) do
    if line:match(text) then
      return i -- Returns line number and content
    end
  end

  return nil -- Not found
end

local function version_to_number(version)
  local major, minor, patch = version:match("(%d+)%.(%d+)%.(%d+)")
  return tonumber(major) * 10000 + tonumber(minor) * 100 + tonumber(patch)
end

--- @param package Package
--- @return VersionedPackage
local function get_latest_version(package)
  local result = vim
    .system({ "dotnet", "package", "search", "--exact-match", package.id, "--format", "json" }, { text = true })
    :wait()

  local decoded = vim.json.decode(result.stdout)

  --- @type VersionedPackage[]
  local versionResults = {}
  for _, searchResult in ipairs(decoded.searchResult or {}) do
    for _, foundPackage in ipairs(searchResult.packages or {}) do
      table.insert(versionResults, foundPackage)
    end
  end

  table.sort(versionResults, function(a, b)
    return version_to_number(a.version) < version_to_number(b.version)
  end)

  return versionResults[#versionResults]
end

--- @param executableName string
local function executableExists(executableName)
  local result = vim.system({ "which", executableName }, { text = true }):wait()
  vim.print(vim.inspect(result))

  return result.code == 0
end

function M.fetch_version_details()
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local extension = vim.fn.fnamemodify(filepath, ":e")

  if extension ~= "csproj" then
    return
  end

  local namespace = vim.api.nvim_create_namespace("nugetify-diagnostics")
  local executableName = "dotnet"
  local dotnetExists = executableExists(executableName)

  if not dotnetExists then
    vim.print("Dotnet does not exist. Skipping.")
    return
  end

  vim.system({ "dotnet", "list", filepath, "package", "--format", "json" }, { text = true }, function(result)
    local res = vim.split(result.stdout, "\n")

    --- we have to schedule this on the main event loop, since accessing certain internal vim details is not allowed on the fast event loop
    vim.schedule(function()
      if result.code == 0 then
        local data = vim.json.decode(result.stdout)

        --- @type Package[]
        local packages = {}
        for _, project in ipairs(data.projects or {}) do
          for _, framework in ipairs(project.frameworks or {}) do
            for _, pkg in ipairs(framework.topLevelPackages or {}) do
              table.insert(packages, pkg)
            end
          end
        end

        local diagnosticDetails = {}

        for _, package in ipairs(packages) do
          local line = find_line_with_text(package.id)
          local latestVersion = get_latest_version(package)
          local severity = vim.diagnostic.severity.HINT

          local text = string.format("✓ %s", package.requestedVersion)

          if latestVersion.version ~= package.requestedVersion then
            text = string.format("↑: %s", latestVersion.version)
            severity = vim.diagnostic.severity.WARN
          end
          table.insert(diagnosticDetails, {
            lnum = line - 1,
            message = text,
            severity = severity,
            col = 0,
          })
        end
        M.show_version_details_hint(namespace, bufnr, diagnosticDetails)
      else
        vim.notify("Error: " .. result.stderr, vim.log.levels.ERROR)
      end
    end)
  end)
end

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.csproj" },
  callback = M.fetch_version_details,
})

vim.api.nvim_create_user_command("Nugetify", M.fetch_version_details, {})
vim.api.nvim_set_keymap("n", "<leader>ng", ":Nugetify<CR>", { noremap = true, silent = true })

return M
