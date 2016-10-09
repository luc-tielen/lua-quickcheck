
--- Helper module for symbolically representing a variable.
-- @classmod lqc.fsm.var
-- @alias var

local Var = {}
local Var_mt = { __index = Var }


--- Creates a symbolic representation of a variable.
-- @param value Value of the variable
-- @return a new variable object
function Var.new(value)
  if value == nil then 
    error 'Need to provide a value to Var!'
  end
  local var = { value = value}
  return setmetatable(var, Var_mt)
end


--- Returns a string representation of the variable
-- @return string representation of the variable
function Var:to_string()
  return '{ var, ' .. self.value .. ' }'
end


return Var

