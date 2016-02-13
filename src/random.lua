
local lib = {}

function lib.seed(seed)
  if not seed then
    -- TODO improve precision of seed, right now 1 s precision!
    -- call into C? 
    seed = os.time()
  end

  math.randomseed(seed)
end

-- Get random number between 0 and 1
function lib.rand()
  return math.random()
end

-- Get random number between 0 and max
function lib.upto(max)
  return math.random(max + 1) - 1
end

-- Get random number between min and max
function lib.between(min, max)
  return math.random(min, max)
end

return lib

