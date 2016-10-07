
--- Helper module providing various generators for generating data.
-- @module lqc.lqc_gen
-- @alias lib

local Gen = require 'lqc.generator'
local random = require 'lqc.random'
local reduce = require 'lqc.helpers.reduce'

local lib = {}

--- Picks a number randomly between min and max.
-- @param min Minimum value to pick from
-- @param max Maximum value to pick from
-- @return a random value between min and max
local function choose_pick(min, max)
  local function pick()
    return random.between(min, max)
  end
  return pick
end

--- Shrinks a value between min and max by dividing the sum of the closest
--  number to 0 and the generated value with 2. 
-- This effectively reduces it to the value closest to 0 gradually in the
-- chosen range.
-- @param min Minimum value to pick from
-- @param max Maximum value to pick from
-- @return a shrunk value between min and max
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

--- Creates a generator, chooses an integer between min and max (inclusive range).
-- @param min Minimum value to pick from
-- @param max Maximum value to pick from
-- @return a random value between min and max
function lib.choose(min, max)
  return Gen.new(choose_pick(min, max), choose_shrink(min, max))
end


--- Select a generator from a list of generators
-- @param generators Table containing an array of generator objects.
-- @return A new generator that randomly uses 1 of the generators in the list.
function lib.oneof(generators)
  local which  -- shared state between pick and shrink needed to shrink correctly

  local function oneof_pick(numtests)
    which = random.between(1, #generators)
    return generators[which]:pick(numtests)
  end
  local function oneof_shrink(prev)
    return generators[which]:shrink(prev)
  end

  return Gen.new(oneof_pick, oneof_shrink)
end


--- Select a generator from a list of weighted generators ({{weight1, gen1}, ... })
-- @param generators A table containing an array of weighted generators.
-- @return A new generator that randomly uses a generator from the list, taking the
--         weights into account.
function lib.frequency(generators)
  local which

  local function do_sum(generator, acc) return generator[1] + acc end
  local function frequency_pick(numtests)
    local sum = reduce(generators, 0, do_sum)
    
    local val = random.between(1, sum)
    which = reduce(generators, { 0, 1 }, function(generator, acc)
      local current_sum = acc[1] + generator[1]
      if current_sum >= val then
        return acc
      else
        return { current_sum, acc[2] + 1 }
      end
    end)[2]
    
    return generators[which][2]:pick(numtests)
  end
  local function frequency_shrink(prev)
    return generators[which][2]:shrink(prev)
  end

  return Gen.new(frequency_pick, frequency_shrink)
end

--- Create a generator that selects an element based on the input list.
-- @param array an array of constant values
-- @return Generator that can pick 1 of the values in the array, shrinks
--         towards beginning of the list.
function lib.elements(array)
  local last_idx
  local function elements_pick()
    local idx = random.between(1, #array)
    last_idx = idx
    return array[idx]
  end

  local function elements_shrink(_)
    if last_idx > 1 then
      last_idx = last_idx - 1
    end
    return array[last_idx]
  end

  return Gen.new(elements_pick, elements_shrink)
end

return lib

