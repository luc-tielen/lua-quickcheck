
local Var = {}
local Var_mt = { __index = Var }


-- Creates a symbolic representation of a variable.
function Var.new(value)
  if value == nil then 
    error 'Need to provide a value to Var!'
  end
  local var = { value = value}
  return setmetatable(var, Var_mt)
end


-- Returns a string representation of a variable
function Var:to_string()
  return '{ var, ' .. self.value .. ' }'
end


return Var

