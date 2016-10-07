
--- Helper module for managing the config in the application.
-- @module lqc.config
-- @alias config

local config = {}

--- Helper function for getting the default random seed.
--
-- @return default seed used by the application (the current timestamp).
function config.default_seed()
  return os.time()
end


local default_config = {
  files_or_dirs = { '.' },
  seed = config.default_seed(),
  numtests = 100,
  numshrinks = 100,
  colors = false,
  threads = 1,
  check = false
}


--- Checks if the argument is empty (nil or {}).
--
-- @param x Argument to check
-- @return true if arg is empty; otherwise false.
local function is_empty_arg(x)
  return x == nil or (type(x) == 'table' and #x == 0)
end


--- Determines the config to use based on the table of supplied values.
-- If no value is supplied for a specific setting, a default value is used
-- (see top of file).
--
-- @return the updated config
function config.resolve(values)
  for _, arg_name in ipairs { 'files_or_dirs', 'seed', 
                              'numtests', 'numshrinks',
                              'colors', 'threads', 'check' } do
    if is_empty_arg(values[arg_name]) then
      values[arg_name] = default_config[arg_name]
    end
  end
  return values
end


return config

