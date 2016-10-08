
--- Helper module for reducing an array of values into a single value.
-- @module lqc.helpers.reduce
-- @alias reeduce

--- Helper function that performs the actual reduce operation
-- @param array List of elements to be reduced into 1 value
-- @param acc Accumulator containing the temporary result
-- @param func Function to be applied for each element in the array. Takes 2
--             arguments: element out of the array and the current state of the
--             accumulator. Returns the updated accumulator state
-- @param pos Position in the array to apply the reduce operation on
-- @return the result obtained by reducing the array into 1 value
local function do_reduce(array, acc, func, pos)
  if pos < #array then
    local new_pos = pos + 1
    return do_reduce(array, func(array[new_pos], acc), func, new_pos)
  end

  return acc
end

--- Reduces an array of values into a single value
-- @param array List of elements to be reduced into 1 value
-- @param start Start value of the accumulator
-- @param func Function to be applied for each element in the array. Takes 2
--             arguments: element out of the array and the current state of the
--             accumulator. Returns the updated accumulator state
-- @return the result obtained by reducing the array into 1 value
local function reduce(array, start, func)
  return do_reduce(array, start, func, 0)
end

return reduce

