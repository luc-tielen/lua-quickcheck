local Gen = require 'lqc.generator'

-- TODO rename to real!

-- Picks a random float (between - numtests / 2 and numtests / 2).
local function float_pick(numtests)
  local lower_bound = - numtests / 2
  local upper_bound = numtests / 2
  return lower_bound + math.random() * (upper_bound - lower_bound)
end

-- Shrinks a float
local function float_shrink(prev)
  return prev / 2
end

local function new()
  return Gen.new(float_pick, float_shrink)
end

return new

