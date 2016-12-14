
--- Module for pre-loading all lqc modules so the user does not have to do this.
-- @module lqc.cli.loader
-- @alias lib


local deep_copy = require 'lqc.helpers.deep_copy'
local fs = require 'lqc.helpers.fs'
local has_moonscript, moonscript = pcall(require, 'moonscript')


local lib = {}

-- Prepare new global env for easier use of property based testing library
local new_global_env = deep_copy(_G)
new_global_env.Generator = require 'lqc.generator'
new_global_env.any = require 'lqc.generators.any'
new_global_env.bool = require 'lqc.generators.bool'
new_global_env.byte = require 'lqc.generators.byte'
new_global_env.char = require 'lqc.generators.char'
new_global_env.float = require 'lqc.generators.float'
new_global_env.int = require 'lqc.generators.int'
new_global_env.str = require 'lqc.generators.string'
new_global_env.tbl = require 'lqc.generators.table'
new_global_env.random = require 'lqc.random'
new_global_env.property = require 'lqc.property'
new_global_env.fsm = require 'lqc.fsm'
new_global_env.state = require 'lqc.fsm.state'
new_global_env.command = require 'lqc.fsm.command'
do
  local lqc_gen = require 'lqc.lqc_gen'
  new_global_env.choose = lqc_gen.choose
  new_global_env.frequency = lqc_gen.frequency
  new_global_env.elements = lqc_gen.elements
  new_global_env.oneof = lqc_gen.oneof
end


--- Compatibility workaround: setfenv is removed from Lua for versions > 5.1.
--  This function aims to provide same functionality.
--  Based mostly on http://leafo.net/guides/setfenv-in-lua52-and-above.html
--  @param func function for which the environment should be changed
--  @param new_env table containing the new environment to be set
local function setfenv_compat(func, new_env)
  local idx = 1
  repeat
    local name = debug.getupvalue(func, idx)
    if name == '_ENV' then
      debug.upvaluejoin(func, idx, function() return new_env end, 1)
    end
    idx = idx + 1
  until name == '_ENV' or name == nil

  return func
end

local setfenv = setfenv or setfenv_compat


--- Loads a script, sets a new environment (for easier property based testing),
-- @param file_path Path to the file containing a Lua/Moonscript script
-- @return the modified script which can be called as a function.
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

