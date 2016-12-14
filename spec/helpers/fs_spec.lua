local fs = require 'lqc.helpers.fs'
local map = require 'lqc.helpers.map'


describe('file system helper module', function()

  describe('find_files', function()
    it('should return a table containing all files in a dir and its subdirs', function()
      local dir1 = 'spec/moonscript'
      local dir2 = 'spec/generators'
      local files1 = fs.find_files(dir1)
      local files2 = fs.find_files(dir2)
      local expected1 = map({
        'fsm/fsm_spec.moon',
        'fsm/state_spec.moon',
        'integration_spec.moon'
      }, function(f) return dir1 .. '/' .. f end)
      local expected2 = map({
        'C/float_spec.lua',
        'C/64bit_spec.lua',
        'C/basic_spec.lua',
        'C/custom_spec.lua',
        'C/string_spec.lua',
        'bool_spec.lua',
        'byte_spec.lua',
        'char_spec.lua',
        'float_spec.lua',
        'table_spec.lua',
        'any_spec.lua',
        'int_spec.lua',
        'string_spec.lua'
      }, function(f) return dir2 .. '/' .. f end)

      table.sort(files1)
      table.sort(files2)
      table.sort(expected1)
      table.sort(expected2)

      assert.same(expected1, files1)
      assert.same(expected2, files2)
    end)
  end)

  -- TODO tests for is_file, is_dir, is_lua_file and is_moonscript_file
end)

