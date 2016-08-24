local Gen = require 'lqc.generator'
local random = require 'lqc.random'
local abs = math.abs


-- Picks a random integer, bounded by min and max. (min <= int <= max)
local function pick_bounded(min, max)
  local function do_pick() return random.between(min, max) end
  return do_pick
end

-- Returns the number closest to 0.
local function find_closest_to_zero(a, b)
  return (abs(a) < abs(b)) and a or b
end

-- Shrinks an integer, bounded by min and max. (min <= int <= max)
-- Returns a shrunk integer (shrinks towards 0 / closest value to 0 determined
--                           by min and max)
local function shrink_bounded(min, max)
  local bound_limit = find_closest_to_zero(min, max)
  local function do_shrink(previous)
    if previous == 0 or previous == bound_limit then return previous end
    if previous > 0 then return math.floor(previous / 2) end
    return math.ceil(previous / 2)
  end
  return do_shrink
end

-- Picks a random integer, uniformy spread between +- sample_size / 2.
local function pick_uniform(sample_size)
  local value = sample_size / 2
  return random.between(value - sample_size, value)
end

-- Shrinks an integer by dividing it by 2 and rounding towards 0.
local function shrink(previous)
  if previous == 0 then return 0 end
  if previous > 0 then return math.floor(previous / 2) end
  return math.ceil(previous / 2)
end


-- Picks an integer between min and max.
local function integer_between(min, max)
  return Gen.new(pick_bounded(min, max), shrink_bounded(min, max))
end

-- Picks a positive integer between 0 and max.
local function positive_integer(max)
  return Gen.new(pick_bounded(0, max), shrink)
end

-- Picks an integer uniformly chosen between +- sample_size / 2.
local function integer()
  return Gen.new(pick_uniform, shrink)
end

-- Creates a new int generator.
local function new(nr1, nr2)
  if nr1 and nr2 then return integer_between(nr1, nr2) end
  if nr1 then return positive_integer(nr1) end
  return integer()
end

return new

