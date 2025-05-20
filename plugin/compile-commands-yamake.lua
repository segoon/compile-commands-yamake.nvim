local function generate_compile_commands(root, with_codegen)
  print('\nGenerating compile_commands.json...')
  if with_codegen then
    vim.system({'ya', 'make', '--add-result=', '--replace-result'}, function(obj)
      vim.schedule(function() vim.notify({'"Codegen files are generated"'}) end)
    end)
  end

  -- --force-build-depends means "build tests too"
  vim.system({'ya', 'dump', 'compile_commands', '--force-build-depends'},
    function(obj)
      local file = io.open(root .. '/compile_commands.json', 'w')
      file:write(obj.stdout)
      file:close()
      vim.schedule(function() vim.notify({'"compile_commands.json is generated"'}) end)
    end
  )
end

local function ask_for_compile_commands()
  local root = vim.fs.root(0, {'service.yaml', 'library.yaml', 'codegen-module.yaml'})
  if not root then
    root = vim.fs.root(0, {'ya.make'})
  end
  if not root then
    -- Not arcadia
    return
  end
  if vim.fs.root(0, {'compile_commands.json'}) then
    -- Already generated
    return
  end
 
  vim.ui.input({prompt = 'Generate compile_commands.json for ' .. root .. '? [Y/n]'}, 
    function(input)
      if input == '' or input == 'y' then
        generate_compile_commands(root, true)
      end
    end
  )
end

vim.api.nvim_create_autocmd(
  {'BufReadPost'},  {
    pattern = {'*.cpp', '*.hpp'},
    callback = ask_for_compile_commands,
  }
)

vim.api.nvim_create_user_command(
  'GenerateCompileCommands',
  function(args)
    local root = vim.fs.root(0, {'service.yaml', 'codegen-module.yaml'})
    if not root then
      root = vim.fs.root(0, {'ya.make'})
    end
    generate_compile_commands(root, true)
  end,
  {}
)
