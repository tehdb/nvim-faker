local api = vim.api
local faker_cli = require('nvim-faker.faker-cli')

local M = {}

local config = {
  -- TODO:
  -- locale = 'en',
  npm_package = '@tehdb/faker-cli',
  use_global_package = false,
}

function M.setup(user_config)
  config = vim.tbl_deep_extend('force', config, user_config or {})
end

local function print_error(error, show_help)
  show_help = show_help or true
  vim.api.nvim_err_writeln(error)

  if show_help then
    print('Usage: Faker <module> <function> [param-value]... [param-key:param-value]... [locale]')
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

api.nvim_create_user_command('Faker', function(opts)
  local output, err =
    faker_cli.execute_faker_cli_command(opts.args, config.use_global_package, config.npm_package)

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
})

return M
