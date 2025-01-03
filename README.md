# nvim-faker

A neovim plugin for generating fake data. It can be used to create random names, addresses, phone numbers, and other types of data, which is useful for testing and development purposes. It uses [@tehdb/faker-cli](https://www.npmjs.com/package/@tehdb/faker-cli) under the hood which is based on [Faker](https://fakerjs.dev)

## 📦 Install

### Prerequisites

- [node.js](https://nodejs.org) in at least version 18.0.0 or higher
- [npm](https://www.npmjs.com) in at least version 9.0.0 or higher

> For faster `:Faker` command executions, it is recommended to install the faker CLI as a global npm package using `npm i -g @tehdb/faker-cli`. Otherwise, [npx](https://docs.npmjs.com/cli/v11/commands/npx) is used to run faker commands, which consumes more time to execute.

### With [lazy.nvim](https://lazy.folke.io)

```lua

{
  'tehdb/nvim-faker',
  config = function()
    require('nvim-faker').setup({
      use_global_package = true -- use gloabl npm package otherwise npx (default: false)
    })
  end
}
```

### With [LuaRocks](https://luarocks.org)

```sh
luarocks install nvim-faker
```

#### or with [rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim)

```lua
:Rocks nvim-faker
```

#### using init.lua

```lua
require('faker').setup{}
```

#### using init.vim

```vim
lua << EOF
require('faker').setup{}
EOF
```

## 🪄 Commands

`:Faker <module> <function> [param-value]... [param-key:param-value]... [locale]`

> For modules and supported functions see [faker api reference](https://fakerjs.dev/api/)<br/>
> For supported locales see [available locales](https://fakerjs.dev/guide/localization.html#available-locales)

### Autocompletion

When you type the `:Faker` command and press `<space>` followed by `<tab>`, completions for the faker modules will appear. After choosing or typing a faker module and pressing `<space>` and `<tab>` again, completions for the selected faker module functions will be displayed.

### Examples

```lua
:Faker lorem words
:Faker lorem words de
:Faker lorem words 5
:Faker lorem words 5 de
:Faker lorem words min:4 max:5
:Faker lorem words min:4 max:5 de
:Faker lorem sentences 2 '<br>'
:Faker lorem sentences 2 '<br>' de
```

## License MIT
