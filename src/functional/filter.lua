
local function filter(array, predicate)
  local result = {}
  
  for idx = 1, #array do
    local value = array[idx]
    if predicate(value) then
      result[#result + 1] = value
    end
  end

  return result
end

return filter

