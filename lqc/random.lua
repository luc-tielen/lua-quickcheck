
--- Helper module for generating random numbers.
-- @module lqc.random
-- @alias lib

local time = os.time
local random_seed = math.randomseed
local random = math.random

local lib = {}


--- Seeds the random number generator
-- @param seed Random seed (number) or nil for current timestamp
-- @return The random seed used to initialize the random number generator with.
function lib.seed(seed)
  if not seed then seed = time() end
  random_seed(seed)
  return seed
end


--- Get random number between min and max
-- @param min Minimum value to generate a random number in
-- @param max Maximum value to generate a random number in (inclusive)
function lib.between(min, max)
  return random(min, max)
end


return lib

