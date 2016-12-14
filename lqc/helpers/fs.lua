
--- Helper module for everything filesystem related.
-- @module lqc.helpers.fs
-- @alias lib

local lfs = require 'lfs'
local Vector = require 'lqc.helpers.vector'

local lib = {}


--- Concatenates multiple strings together into 1 big string
-- @param strings array of strings to be concatenated together
-- @return the concatenated string
local function strcat(...) return table.concat({ ... }) end


--- Checks if 'f' is a file?
-- @param f string of a file path
-- @return true if f is a file; otherwise false
function lib.is_file(f)
  return lfs.attributes(f, 'mode') == 'file'
end


--- Check if 'd' is a directory?
-- @param d string of a directory path
-- @return true if d is a directory; otherwise false
function lib.is_dir(d)
  return lfs.attributes(d, 'mode') == 'directory'
end


--- Is the file a Lua file? (=a file ending in .lua)
-- @param file path to a file
-- @return true if it is a Lua file; otherwise false.
function lib.is_lua_file(file)
  return file:match('%.lua$') ~= nil
end


--- Is the file a Moonscript file? (= a file ending in .moon)
-- @param file path to a file
-- @return true if it is a Moonscript file; otherwise false.
function lib.is_moonscript_file(file)
  return file:match('%.moon$') ~= nil
end


--- Removes a file from the filesystem.
-- @param path Path to the file that should be removed
function lib.remove_file(path)
  os.remove(path)
end


--- Checks if a file exists.
-- @param path path to a file
-- @return true if the file does exist; otherwise false
function lib.file_exists(path)
  return lfs.attributes(path) ~= nil
end


--- Reads the entire contents from a (binary) file and returns it.
-- @param path path to the file to read from
-- @return the contents of the file as a string or nil on error
function lib.read_file(path)
  local file = io.open(path, 'rb')
  if not file then return nil end
  local contents = file:read '*a'
  file:close()
  return contents
end


--- Writes the 'new_contents' to the (binary) file specified by 'path'
-- @param path path to file the contents should be written to
-- @param new_contents the contents that will be written
-- @return nil; raises an error if file could not be opened.
function lib.write_file(path, new_contents)
  if not new_contents then return end
  local file = io.open(path, 'wb')
  if not file then error('Could not write to ' .. path .. '!') end
  file:write(new_contents)
  file:close()
end


--- Finds all files in a directory.
-- @param directory_path String of a directory path
-- @return a table containing all files in this directory and it's
--         subdirectories. Raises an error if dir is not a valid
--         string to a directory path.
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

