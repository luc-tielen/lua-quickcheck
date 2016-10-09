
--- Module for generating integer values
-- @module lqc.generators.int
-- @alias new

local Gen = require 'lqc.generator'
local random = require 'lqc.random'
local abs = math.abs


--- Helper function for picking a random integer, bounded by min and max. 
-- @param min minimum value
-- @param max maximum value
-- @return function that can generate an integer (min <= int <= max)
local function pick_bounded(min, max)
  local function do_pick() return random.between(min, max) end
  return do_pick
end


--- Helper function for finding number closest to 0.
-- @param a number 1
-- @param b number 2
-- @return number closest to 0
local function find_closest_to_zero(a, b)
  return (abs(a) < abs(b)) and a or b
end


--- Helper function for shrinking integer, bounded by min and max. (min <= int <= max)
-- @param min minimum value
-- @param max maximum value
-- @return shrunk integer (shrinks towards 0 / closest value to 0 determined
--         by min and max)
local function shrink_bounded(min, max)
  local bound_limit = find_closest_to_zero(min, max)
  local function do_shrink(previous)
    if previous == 0 or previous == bound_limit then return previous end
    if previous > 0 then return math.floor(previous / 2) end
    return math.ceil(previous / 2)
  end
  return do_shrink
end


--- Picks a random integer, uniformy spread between +- sample_size / 2.
-- @param sample_size Number of times this generator is used in a property;
--                    used to guide the optimatization process.
-- @return random integer
local function pick_uniform(sample_size)
  local value = sample_size / 2
  return random.between(value - sample_size, value)
end


--- Shrinks an integer by dividing it by 2 and rounding towards 0.
-- @param previous previously generated integer value
-- @return shrunk down integer value
local function shrink(previous)
  if previous == 0 then return 0 end
  if previous > 0 then return math.floor(previous / 2) end
  return math.ceil(previous / 2)
end


--- Creates a generator for generating an integer between min and max.
-- @param min minimum value
-- @param max maximum value
-- @return generator that generates integers between min and max.
local function integer_between(min, max)
  return Gen.new(pick_bounded(min, max), shrink_bounded(min, max))
end


--- Creates a generator for generating a positive integer between 0 and max.
-- @param max maximum value
-- @return generator that generates integer between 0 and max.
local function positive_integer(max)
  return Gen.new(pick_bounded(0, max), shrink)
end


--- Creates a generator for generating an integer uniformly chosen 
--  between +- sample_size / 2.
-- @return generator that can generate an integer
local function integer()
  return Gen.new(pick_uniform, shrink)
end


--- Creates a new integer generator.
-- @param nr1 number containing first bound
-- @param nr2 number containing second bound
-- @return generator that can generate integers according to the following strategy:
--   - nr1 and nr2 provided: nr1 <= int <= nr2
--   - only nr1 provided: 0 <= int <= max
--   - no bounds provided: -numtests/2 <= int <= numtests/2
local function new(nr1, nr2)
  if nr1 and nr2 then return integer_between(nr1, nr2) end
  if nr1 then return positive_integer(nr1) end
  return integer()
end

return new

