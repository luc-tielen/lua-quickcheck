
--- Module for generating float values.
-- @lqc.generators.float
-- @alias new

local Gen = require 'lqc.generator'


-- Generates a random float.
-- @param numtests Number of times this generator is called in a test; used to
--                 guide the randomization process.
-- @return random float (between - numtests / 2 and numtests / 2).
local function float_pick(numtests)
  local lower_bound = - numtests / 2
  local upper_bound = numtests / 2
  return lower_bound + math.random() * (upper_bound - lower_bound)
end

--- Shrinks a float to a simpler value
-- @param prev a previously generated float value
-- @return shrunk down float value
local function float_shrink(prev)
  return prev / 2
end


--- Creates a generator for float values
-- @return a generator that can generate float values.
local function new()
  return Gen.new(float_pick, float_shrink)
end

return new

