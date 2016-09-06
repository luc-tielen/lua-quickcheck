
local time = os.time
local random_seed = math.randomseed
local random = math.random

local lib = {}


-- Seeds the random number generator
function lib.seed(seed)
  if not seed then seed = time() end
  random_seed(seed)
  return seed
end


-- Get random number between min and max
function lib.between(min, max)
  return random(min, max)
end


return lib

