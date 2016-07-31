local deep_copy = require 'src.helpers.deep_copy'
local fs = require 'src.helpers.fs'
local has_moonscript, moonscript = pcall(require, 'moonscript')


local lib = {}

-- Prepare new global env for easier use of property based testing library
local new_global_env = deep_copy(_G)
new_global_env.Generator = require 'src.generator'
new_global_env.any = require 'src.generators.any'
new_global_env.bool = require 'src.generators.bool'
new_global_env.byte = require 'src.generators.byte'
new_global_env.char = require 'src.generators.char'
new_global_env.float = require 'src.generators.float'
new_global_env.int = require 'src.generators.int'
new_global_env.str = require 'src.generators.string'
new_global_env.tbl = require 'src.generators.table'
new_global_env.random = require 'src.random'
new_global_env.property = require 'src.property'
new_global_env.fsm = require 'src.fsm'
new_global_env.state = require 'src.fsm.state'
new_global_env.command = require 'src.fsm.command'
do
  local lqc_gen = require 'src.lqc_gen'
  new_global_env.choose = lqc_gen.choose
  new_global_env.frequency = lqc_gen.frequency
  new_global_env.elements = lqc_gen.elements
  new_global_env.oneof = lqc_gen.oneof
end


-- Loads a script, sets a new environment (for easier property based testing),
-- then returns the modified script which can be called as a function.
function lib.load_script(file_path)
  -- Check if Moonscript file and if Moonscript available
  if fs.is_moonscript_file(file_path) then
    if not has_moonscript then return function() end end  -- return empty 'script'
    
    local script = moonscript.loadfile(file_path)
    return setfenv(script, new_global_env)
  end

  -- Lua file
  local script = loadfile(file_path)
  return setfenv(script, new_global_env)
end


return lib

