
--- Helper module for filtering elements out of an array based on a predicate.
-- @module lqc.helpers.filter
-- @alias filter

--- Filters an array based on a predicate function
-- @param array List of values in a table
-- @param predicate Function taking 1 argument (element in the array), returns
--                  a bool indicating if element should be removed or not
-- @return new array containing only the values for which the predicate is true
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

