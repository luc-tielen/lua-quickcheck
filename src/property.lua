
local lib = {}
local all = {}  -- list of all properties, TODO refactor into checker.lua?
lib.all = all

-- property is same as function but with an added description
local function new(descr, func)
  local prop = {
    description = descr,
    prop_func = func
  }
  return setmetatable(prop, { __call = function(self)
    return self.prop_func()
  end })
end

function lib.property(descr, func)
  table.insert(all, new(descr, func))
end

return lib

