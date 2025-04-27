local function ask_for_compile_commands()
      local root = vim.fs.root(0, {'service.yaml', 'codegen-module.yaml'})
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
	    print('\nGenerating compile_commands.json...')
            vim.system({'ya', 'dump', 'compile_commands'},
	      function(obj)
                local file = io.open(root .. '/compile_commands.json', 'w')
                file:write(obj.stdout)
                file:close()
		vim.schedule(function() vim.cmd.echo({'"compile_commands.json is generated"'}) end)
	      end
            )
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
