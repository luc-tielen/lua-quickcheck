
local time = os.time
local random_seed = math.randomseed
local random = math.random

local lib = {}

function lib.seed(seed)
  -- TODO improve precision of seed, right now 1 s precision!
  -- call into C? 
  if not seed then seed = time() end
  random_seed(seed)
  return seed
end

-- Get random number between min and max
function lib.between(min, max)
  return random(min, max)
end


return lib

