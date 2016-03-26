local Gen = require 'src.generator'
local random = require 'src.random'

local lib = {}

-- Picks a number randomly between min and max.
local function choose_pick(min, max)
  local function pick()
    return random.between(min, max)
  end
  return pick
end

-- Shrinks a value between min and max by dividing the sum of the closest
-- number to 0 and the generated value with 2. 
-- This effectively reduces it to the value closest to 0 gradually in the
-- chosen range.
local function choose_shrink(min, max)
  local shrink_to = (math.abs(min) < math.abs(max)) and min or max

  local function shrink(value)
    local shrunk_value = (shrink_to + value) / 2
  
    if shrunk_value < 0 then
      return math.ceil(shrunk_value)
    else
      return math.floor(shrunk_value)
    end
  end

  return shrink
end

-- Creates a generator, chooses an integer between min and max.
function lib.choose(min, max)
  return Gen.new(choose_pick(min, max), choose_shrink(min, max))
end

return lib

