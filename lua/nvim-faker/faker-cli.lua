local M = {}

local semver_pattern = '^%d+%.%d+%.%d+$'

function M.is_globally_installed(npm_package)
  local output = vim.fn.system('faker --info')
  return output:sub(1, 17) == npm_package
end

function M.ensure_npx_cache(npm_package)
  local cmd = 'npx --yes ' .. npm_package .. ' --version'
  local result = vim.fn.system(cmd)
  if result:match(semver_pattern) then
    return true
  else
    return false
  end
end

function M.execute_faker_cli_command(params, use_global_package, npm_package)
  local fakerCmd = ''
  if use_global_package then
    fakerCmd = 'faker'
  else
    fakerCmd = 'npx --yes ' .. npm_package
  end

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

return M
