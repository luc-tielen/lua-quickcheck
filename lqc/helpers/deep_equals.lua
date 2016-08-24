
local pairs = pairs


-- Checks 1 value is equal to another. Also works for nested structures.
local function deep_equals(a, b)
  local type_a = type(a)
  if type_a ~= type(b) then return false end
  if type_a ~= 'table' then return a == b end
  
  if #a ~= #b then return false end
  for k, v1 in pairs(a) do
    local v2 = b[k]
    if type(v1) == 'table' then return deep_equals(v1, v2) end
    if v1 ~= v2 then return false end
  end

  return true
end

return deep_equals

