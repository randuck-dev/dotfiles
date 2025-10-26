local async = require("plenary.async")

local M = {}

---@class Receiver
---@field recv function

---@class Sender
---@field send fun(value: any)

---@class Package
---@field id string
---@field requestedVersion string?
---@field resolvedVersion string

---@class VersionedPackage
---@field id string
---@field version string

---@class PackageDetails
---@field package Package
---@field latestVersion VersionedPackage

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

--- @param inputText string[]
--- @param text string
--- @return integer | nil
local function find_line_with_text(inputText, text)
  local lines = inputText

  for i, line in ipairs(lines) do
    if line:match(text) then
      return i -- Returns line number and content
    end
  end

  return nil -- Not found
end

--- @param version string
local function version_to_number(version)
  --- @type string, string, string
  local major, minor, patch = version:match("(%d+)%.(%d+)%.(%d+)")
  return tonumber(major) * 10000 + tonumber(minor) * 100 + tonumber(patch)
end

--- @param package Package
--- @param sender Sender
local function get_latest_version(package, sender)
  vim.system(
    { "dotnet", "package", "search", "--exact-match", package.id, "--format", "json" },
    { text = true },
    function(result)
      local decoded = vim.json.decode(result.stdout)

      --- @type VersionedPackage[]
      local versionResults = {}
      for _, searchResult in ipairs(decoded.searchResult or {}) do
        for _, foundPackage in ipairs(searchResult.packages or {}) do
          table.insert(versionResults, foundPackage)
        end
      end

      --- we want to make sure that the version results are in descending order based on the semantic versioning
      table.sort(versionResults, function(a, b)
        return version_to_number(a.version) < version_to_number(b.version)
      end)

      sender.send({
        package = package,
        latestVersion = versionResults[#versionResults],
      })
    end
  )
end

--- @param executableName string
local function executableExists(executableName)
  local result = vim.system({ "which", executableName }, { text = true }):wait()
  return result.code == 0
end

--- @param wait_for_n integer
--- @param receiver Receiver
--- @param inputText string[]
--- @param bufnr integer
--- @param namespace integer
local function consume_details(wait_for_n, receiver, inputText, bufnr, namespace)
  local diagnosticDetails = {}
  for _ = 1, wait_for_n do
    ---@type PackageDetails | nil
    local details = receiver:recv()
    if not details then
      vim.notify("no details found")
    else
      local package = details.package
      local line = find_line_with_text(inputText, package.id)
      if not line then
        return
      end
      local severity = vim.diagnostic.severity.HINT

      local text = string.format("✓ %s", package.requestedVersion)
      local latestVersion = details.latestVersion

      if latestVersion.version ~= package.requestedVersion then
        text = string.format("↑: %s", latestVersion.version)
        severity = vim.diagnostic.severity.WARN
      end
      local diagnostics = {
        lnum = line - 1,
        message = text,
        severity = severity,
        col = 0,
      }

      table.insert(diagnosticDetails, diagnostics)
    end
  end

  vim.schedule(function()
    M.show_version_details_hint(namespace, bufnr, diagnosticDetails)
  end)
end

function M.fetch_version_details()
  local sender, receiver = async.control.channel.mpsc()
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local extension = vim.fn.fnamemodify(filepath, ":e")

  if extension ~= "csproj" then
    return
  end

  local namespace = vim.api.nvim_create_namespace("nugetify-diagnostics")
  local executableName = "dotnet"
  local dotnetExists = executableExists(executableName)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  if not dotnetExists then
    vim.print("Dotnet does not exist. Skipping.")
    return
  end

  vim.system({ "dotnet", "list", filepath, "package", "--format", "json" }, { text = true }, function(result)
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

      async.run(function()
        local ok, err = pcall(function()
          consume_details(#packages, receiver, lines, bufnr, namespace)
        end)

        if not ok then
          vim.schedule(function()
            vim.notify("An error occured" .. tostring(err))
          end)
        end
      end, function() end)

      for _, package in ipairs(packages) do
        get_latest_version(package, sender)
      end
    else
      vim.notify("Error: " .. result.stderr, vim.log.levels.ERROR)
    end
  end)
end

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.csproj" },
  callback = M.fetch_version_details,
})

vim.api.nvim_create_user_command("Nugetify", M.fetch_version_details, {})
vim.api.nvim_set_keymap("n", "<leader>ng", ":Nugetify<CR>", { noremap = true, silent = true })

return M
