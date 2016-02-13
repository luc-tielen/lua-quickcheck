random = require "random"

local lib = {}
local limit = 2 ^ 64

function lib.pick()
  -- TODO check limit is correct..
  return random.between(-limit, limit)
end

function lib.shrink(previous)
  -- TODO improve this function after property has been introduced..
  if previous == 0 then return 0 end
  if previous > 0 then return math.floor(previous / 2) end
  return math.ceil(previous / 2)
end

return lib

