local api = vim.api
local faker_cli = require('nvim-faker.faker-cli')

local M = {}
local fakerCliAvaileble = false

local config = {
  -- TODO:
  -- locale = 'en',
  -- npm_package_verison = "0.5.1"
  npm_package = '@tehdb/faker-cli',
  use_global_package = false,
}

function M.setup(user_config)
  config = vim.tbl_deep_extend('force', config, user_config or {})

  -- TODO: check out nvim-nio for async tasks
  vim.schedule(function()
    if config.use_global_package == true then
      fakerCliAvaileble = faker_cli.is_globally_installed(config.npm_package)
    else
      fakerCliAvaileble = faker_cli.ensure_npx_cache(config.npm_package)
    end

    if fakerCliAvaileble then
      faker_cli.init(config.use_global_package, config.npm_package)
    end
  end)
end

local function print_error(error, show_help)
  if show_help == nil then
    show_help = 'usage'
  end

  vim.api.nvim_err_writeln(error)

  if show_help == 'usage' then
    print('Usage: Faker <module> <function> [param-value]... [param-key:param-value]... [locale]')
  elseif show_help == 'install' then
    if config.use_global_package == false then
      print('Check if the package ' .. config.npm_package .. ' exists in the npm registry')
    else
      print(
        "Run 'npm install --global " .. config.npm_package .. "' to install the package globally"
      )
    end
  end
end

local function insert_text(text)
  local lines = vim.split(text, '\n')
  local buf = api.nvim_get_current_buf()
  local row, col = unpack(api.nvim_win_get_cursor(0))

  -- remove last line break
  if #lines > 0 and lines[#lines] == '' then
    table.remove(lines, #lines)
  end

  local start_row = row - 1
  local start_col = col + 1

  if start_col == 1 then
    start_col = 0
  end

  local end_row = start_row
  local end_col = start_col

  api.nvim_buf_set_text(buf, start_row, start_col, end_row, end_col, lines)
end

local function command_args_completion(arg_lead, cmd_line, cursor_pos)
  local faker_modules_map = faker_cli.faker_modules_map

  local module_keys = {}
  for key, _ in pairs(faker_modules_map) do
    table.insert(module_keys, key)
  end

  table.sort(module_keys)

  local args = vim.split(cmd_line, '%s+')

  if #args == 2 then
    return vim.tbl_filter(function(val)
      return vim.startswith(val, arg_lead)
    end, module_keys)
  elseif #args == 3 then
    local first_arg = args[2]
    local module_function_keys = faker_modules_map[first_arg] or {}
    table.sort(module_function_keys)

    return vim.tbl_filter(function(val)
      return vim.startswith(val, arg_lead)
    end, module_function_keys)
  else
    return {}
  end
end

api.nvim_create_user_command('Faker', function(opts)
  if fakerCliAvaileble == false then
    print_error('Error: Faker CLI is not available', 'install')
    return
  end

  if not vim.bo.modifiable then
    print_error("':Faker' command available only in modifiable buffers", false)
    return
  end

  local output, err = faker_cli.execute_faker_cli_command(opts.args)

  if output == nil then
    if err then
      print_error(err)
    else
      print_error('Error: Failed to execute cli command')
    end

    return
  end

  insert_text(output)
end, {
  nargs = '+',
  complete = command_args_completion,
})

return M
