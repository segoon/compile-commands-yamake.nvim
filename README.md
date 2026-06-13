# compile-commands-yamake.nvim

Generates `compile_commands.json` via `ya dump compile_commands` for Arcadia-based projects.

## Installation

### lazy.nvim

```lua
{
  'segoon/compile-commands-yamake.nvim',
  ft = { 'c', 'cpp' },
  opts = {
    mode        = 'ask',
    ignore_dirs = { 'contrib', 'vendor' },
  },
}
```

`opts` is passed directly to `setup()` by lazy.nvim.

### Other plugin managers

Call `setup()` explicitly somewhere in your config:

```lua
require('compile-commands-yamake').setup({
  mode        = 'ask',
  ignore_dirs = {},
})
```

## Configuration

```lua
require('compile-commands-yamake').setup({
  -- File patterns that trigger the autocmd
  patterns = { '*.c', '*.cpp', '*.hpp' },

  -- 'ask'    – prompt the user on file open
  -- 'auto'   – generate silently on file open
  -- 'nothing'– disable the autocmd entirely
  mode = 'ask',

  -- Directories to skip, matched as a full path component
  -- relative to the arcadia root (e.g. the first directory in
  -- the path after the root). Only affects the autocmd.
  ignore_dirs = {},
})
```

## Usage

The plugin triggers on `.c`, `.cpp`, and `.hpp` file opens (configurable via `patterns`).

- **`ask` mode** – prompts whether to generate `compile_commands.json` for the detected arcadia root.
- **`auto` mode** – generates immediately without prompting.
- **`nothing` mode** – autocmd is not registered; use the command below manually.

### User command

`:GenerateCompileCommands` — generate `compile_commands.json` for the arcadia root of the current file, regardless of `mode` or `ignore_dirs`.
