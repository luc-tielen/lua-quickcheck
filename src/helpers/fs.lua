local lfs = require 'lfs'
local Vector = require 'src.helpers.vector'

local lib = {}


-- Concatenates multiple strings together into 1 big string
-- Returns the concatenated string
local function strcat(...) return table.concat({ ... }) end


-- Is 'f' a file?
-- Returns true if f is a file; otherwise false
function lib.is_file(f)
  return lfs.attributes(f, 'mode') == 'file'
end


-- Is 'd' a directory?
-- Returns true if d is a directory; otherwise false
function lib.is_dir(d)
  return lfs.attributes(d, 'mode') == 'directory'
end


-- Is the file a Lua file? (ends in .lua)
-- Returns true if it is a Lua file; otherwise false.
function lib.is_lua_file(file)
  return file:match('%.lua$') ~= nil
end


-- Is the file a Moonscript file? (ends in .moon)
-- Returns true if it is a Moonscript file; otherwise false.
function lib.is_moonscript_file(file)
  return file:match('%.moon$') ~= nil
end


-- Returns a table containing all files in this directory and it's
-- subdirectories. Raises an error if dir is not a valid string to a directory path.
function lib.find_files(directory_path)
  local result = Vector.new()

  for file_name in lfs.dir(directory_path) do
    if file_name ~= '.' and file_name ~= '..' then 
      local file = strcat(directory_path, '/', file_name)
      if lib.is_dir(file) then
        result:append(Vector.new(lib.find_files(file)))
      elseif lib.is_file(file) then
        result:push_back(file)
      end
    end
  end

  return result:to_table()
end


return lib

