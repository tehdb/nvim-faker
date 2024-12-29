local M = {
  faker_modules_map = {},
}
local semver_pattern = '^%d+%.%d+%.%d+$'
local config = {}

local function getCmd()
  local fakerCmd = ''
  if config.use_global_package then
    fakerCmd = 'faker'
  else
    fakerCmd = 'npx --yes ' .. config.npm_package
  end

  return fakerCmd
end

local function trim_and_remove_newlines(str)
  -- Remove newline characters
  str = str:gsub('\n', '')
  -- Trim leading and trailing whitespace
  str = str:match('^%s*(.-)%s*$')
  return str
end

local function cache_availeble_modules()
  -- if not empty then return the in memory cached list
  -- if next(faker_modules_map) ~= nil then
  --   return faker_modules_map
  -- end

  local modules_map = {}
  local fakerCmd = getCmd()

  local output = vim.fn.system(fakerCmd .. '  --available-modules')

  local current_key = nil

  for line in output:gmatch('[^\r\n]+') do
    local key = line:match('^(%w+):$')
    if key then
      current_key = key
      modules_map[current_key] = {}
    elseif current_key then
      local value = line:match('^%s*-%s*(%w+)$')
      if value then
        table.insert(modules_map[current_key], value)
      end
    end
  end

  M.faker_modules_map = modules_map
end

function M.execute_faker_cli_command(params)
  local fakerCmd = getCmd()

  local output = vim.fn.system(fakerCmd .. ' ' .. params)
  local status = vim.v.shell_error

  if status == 0 then
    if output == nil then
      return nil, 'Failed to read the output'
    end

    if output:sub(1, 5) == 'error' then
      return nil, output
    end

    return output
  elseif status == 1 then
    return nil, output
  else
    return nil, 'Unknown error occurred - ' .. output
  end
end

function M.is_globally_installed(npm_package)
  local output = vim.fn.system('faker --info')
  output = trim_and_remove_newlines(output)
  return output:sub(1, string.len(npm_package)) == npm_package
end

function M.ensure_npx_cache(npm_package)
  local output = vim.fn.system('npx --yes ' .. npm_package .. ' --version')
  output = trim_and_remove_newlines(output)

  if output:match(semver_pattern) then
    return true
  else
    return false
  end
end

function M.init(use_global_package, npm_package)
  config.use_global_package = use_global_package
  config.npm_package = npm_package

  cache_availeble_modules()
end
return M
