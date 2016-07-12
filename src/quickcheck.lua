
local shuffle = pairs
local lib = {}

lib.properties = {}  -- list of all properties
lib.iteration_amount = 100  -- TODO make configurable
lib.shrink_amount = 100     -- TODO make configurable


-- Iterates over all properties in a random order and checks if the property
-- holds true for each generated set of inputs.
function lib.check()
  for _, prop in shuffle(lib.properties) do
    prop:check() 
  end
end


return lib

