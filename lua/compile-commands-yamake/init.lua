local M = {}

local default_opts = {
  filetypes   = { 'c', 'cpp' },
  mode        = 'ask',   -- 'ask' | 'auto' | 'nothing'
  ignore_dirs = {},
}

local function generate_compile_commands(root, with_codegen)
  vim.notify('Generating compile_commands.json...')
  if with_codegen then
    vim.system({ 'ya', 'make', '--add-result=', '--replace-result' }, function(_)
      vim.schedule(function()
        vim.notify('Codegen files are generated')
      end)
    end)
  end

  -- --force-build-depends means "build tests too"
  vim.system({ 'ya', 'dump', 'compile_commands', '--force-build-depends' },
    function(obj)
      local file = io.open(root .. '/compile_commands.json', 'w')
      if not file then
        vim.schedule(function()
          vim.notify('Failed to open compile_commands.json for writing', vim.log.levels.ERROR)
        end)
        return
      end
      file:write(obj.stdout)
      file:close()
      vim.schedule(function()
        vim.notify('compile_commands.json is generated')
      end)
    end
  )
end

local function find_arcadia_root()
  return vim.fs.root(0, { 'service.yaml', 'library.yaml', 'codegen-module.yaml' })
    or vim.fs.root(0, { 'ya.make' })
end

local function make_autocmd_callback(opts)
  -- Build a set for O(1) lookup
  local ignore_set = {}
  for _, dir in ipairs(opts.ignore_dirs) do
    ignore_set[dir] = true
  end

  return function()
    local root = find_arcadia_root()
    if not root then
      return
    end
    if vim.fs.root(0, { 'compile_commands.json' }) then
      -- Already generated
      return
    end

    -- ignore_dirs check: full match on the first path component relative to arcadia root
    local file_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':p:h')
    -- +2 to strip the trailing slash of root
    local rel = file_dir:sub(#root + 2)
    local first_component = rel:match('^([^/]+)')
    if first_component and ignore_set[first_component] then
      return
    end

    if opts.mode == 'auto' then
      generate_compile_commands(root, true)
    elseif opts.mode == 'ask' then
      vim.ui.input(
        { prompt = 'Generate compile_commands.json for ' .. root .. '? [Y/n] ' },
        function(input)
          if input == '' or input == 'y' or input == 'Y' then
            generate_compile_commands(root, true)
          end
        end
      )
    end
  end
end

function M.setup(opts)
  opts = vim.tbl_deep_extend('force', default_opts, opts or {})

  -- Always register the user command (no ignore_dirs, no mode check)
  vim.api.nvim_create_user_command(
    'GenerateCompileCommands',
    function(_)
      local root = find_arcadia_root()
      if not root then
        vim.notify('Could not find arcadia root', vim.log.levels.ERROR)
        return
      end
      generate_compile_commands(root, true)
    end,
    { desc = 'Generate compile_commands.json via ya dump compile_commands' }
  )

  if opts.mode == 'nothing' then
    return
  end

  vim.api.nvim_create_autocmd('FileType', {
    pattern  = opts.filetypes,
    callback = make_autocmd_callback(opts),
    desc     = 'compile-commands-yamake: auto-generate compile_commands.json',
  })
end

return M
