# Hatch.nvim

🥚 **Hatch.nvim** is a Neovim plugin that automatically applies file templates
to empty buffers. This plugin helps you start coding faster with pre-defined
boilerplate code for different file types.

## Features

- Automatically inserts templates for empty buffers based on file extension.
- Supports custom templates, or default templates .
  - Supports sharing templates from custom repositories, or pull them from the
    [default repository](https://github.com/codevogel/hatch.nvim-templates)
- Handles cursor placement via a `#cursor row:col` directive, placing your
  cursor right where you want it to be, so you can start coding immediately.

## Demo

![demo gif](./demo/demo.gif)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

**Minimal setup**:

```lua
{
  "codevogel/hatch.nvim",
  opts = {},
}

```

Now optionally run `:HatchCloneTemplates` to clone the [default template
repository](https://github.com/codevogel/hatch.nvim-templates).

## Usage

- Run `:Hatch` to hatch from a template file when in an empty buffer.
  - ℹ️ This is done automatically on `BufWritePre` when saving buffers when
    `create_autocmd = true` (on by default).
- Template files are selected based on file extension from the
  `template_directory` (default: `$HOME/.config/hatch.nvim/templates`)
- Templates can also be forced to overwrite a non-empty buffer using
  `:HatchForce`

## Templates

Templates are read from either `{template_directory}/custom/{file_exension}` or
`{template_directory}/default/{file_exension}`, where the former takes
precedence.

### Setting your cursor from a template

On the first line of a template file, you can add a cursor directive using
`#cursor: row:col`. This makes it easy to get your cursor to the exact place you
start writing code after hatching the template.

e.g.: editing the `template.nix` file, add `#cursor: 4:1` to make your cursor
jump to line 4 (1-indexed), column 2 (0-indexed).

> To make this process easy, just add the `#cursor` line, then place your cursor
> and note down your row:col marker from the bottom right corner of `nvim`, and
> subtract one to both numbers you see there. (subtracting 1 from the row
> because hatch will remove the `#cursor` line, and subtracting 1 from the
> column because they are 0-indexed in `nvim`).

### Pulling templates from a repository

You can set the `template_repository` to your own fork of the
[default template repository](https://github.com/codevogel/hatch.nvim-templates).

This just makes `HatchCloneTemplates` use that URL instead.

You can also just opt to clone a repository anywhere on your machine, and then
set `template_directory` to that path.

### Example: Adding a template for .gd (gdscript) files

Create a file `{template_directory}/default/template.gd` or
`{template_directory}/custom/template.gd`:

```gdscript
#cursor 1:11
class_name Foo

function _ready() -> void:
 pass

function process(delta: float) -> void:
 pass
```

Now any empty buffer that ends in `.gd` will be replaced with above contents,
placing the cursor at the start of `Foo`, so you can immediately `cw` to update
it.

### Running after the formatter

Sometimes it might be useful to make hatch run after the formatter, as your
formatter might remove whitespace that you'd like to be preserved in your
template.

In this case, just set `create_autocmd = false` and then run hatch after your
formatter.

For example, for [conform.nvim](https://github.com/stevearc/conform.nvim) we can
just update the autocmd which formats the buffer to run hatch afterwards:

```lua
vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      callback = function(args)
        require("conform").format({
            -- formatting options...
        })
        require("hatch").hatch()
      end,
    })
```

## Configuration Options

These settings can be supplied to the `setup` function of the plugin in a table.

| Option                | Type    | Default                                               | Description                                   |
| --------------------- | ------- | ----------------------------------------------------- | --------------------------------------------- |
| `template_repository` | string  | `"git@github.com:codevogel/hatch.nvim-templates.git"` | Git repository containing default templates   |
| `template_directory`  | string  | `"$HOME/.config/hatch.nvim/templates"`                | Local directory to store templates            |
| `create_autocmd`      | boolean | `true`                                                | Automatically apply templates on buffer write |

## Commands

| Command                | Description                                                                |
| ---------------------- | -------------------------------------------------------------------------- |
| `:Hatch`               | Apply a template to the current buffer, overwriting its contents if empty. |
| `:HatchForce`          | Force-apply the template to the current buffer, overwriting its contents.  |
| `:HatchCloneTemplates` | Clone the template repository into your local template directory.          |

## Template Directory Structure

```
~/.config/hatch.nvim/templates/
├── default/     # Default templates from the repo
│   ├── template.py       # Python template
│   └── template.lua      # Lua template
└── custom/      # User-defined custom templates
    └── template.js       # JavaScript template
```

- **Custom templates** override default templates when both exist.
- Templates are matched based on file extension.

## License

[MIT](./LICENSE.md)
