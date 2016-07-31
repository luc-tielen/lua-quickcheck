
local shuffle = pairs
local lib = {
  properties = {},  -- list of all properties
  numtests = nil,   -- Default amount of times a property should be tested
  numshrinks = nil  -- Default amount of times a failing property should be shrunk down
}


-- Is the quickcheck configuration initialized?
-- Returns true if it is initialized; otherwise false.
local function is_initialized()
  return lib.numtests ~= nil and lib.numshrinks ~= nil
end


-- Configures the amount of iterations and shrinks the check algorithm should
-- perform.
function lib.init(numtests, numshrinks)
  lib.numtests = numtests
  lib.numshrinks = numshrinks
end


-- Iterates over all properties in a random order and checks if the property
-- holds true for each generated set of inputs.
function lib.check()
  if not is_initialized() then
    error 'quickcheck.init() has to be called before quickcheck.check()!'
  end
  for _, prop in shuffle(lib.properties) do
    prop:check() 
  end
end


return lib

