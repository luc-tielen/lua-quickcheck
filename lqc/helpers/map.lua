
--- Helper moduile for performing a function on each element in an array.
-- @module lqc.helpers.map
-- @alias map

--- Maps a function over an array
-- @param array List of elements on which a function will be applied
-- @param func Function to be applied over the array. Takes 1 argument (element of the array); returns a result
-- @return A new array with func applied to each element in the array
local function map(array, func)
  local result = {}

  for idx = 1, #array do
    result[#result + 1] = func(array[idx])
  end

  return result
end

return map

