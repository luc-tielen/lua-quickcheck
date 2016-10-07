
--- Class for generating (custom) generators.
-- @classmod lqc.generator
-- @alias Gen

local Gen = {}
local Gen_mt = { __index = Gen }


--- Creates a new generator for generating random values.
-- @param pick_func a function that randomly creates a certain datatype.
-- @param shrink_func a function that shrinks (simplifies) a given input based
--                    on last input.
-- @return a generator object
-- @see pick
-- @see shrink
function Gen.new(pick_func, shrink_func)
  local Generator = {
    pick_func = pick_func,
    shrink_func = shrink_func,
  }

  return setmetatable(Generator, Gen_mt)
end

--- Generates a new random value based on this generator's pick value.
--
-- @param numtests amount of times a property will be run, can be used to guide
--                 the choosing process.
-- @return a new randomly chosen value
function Gen:pick(numtests)
  return self.pick_func(numtests)
end

--- Shrinks a generated value to a simpler value.
--
-- @param prev The previously generated value.
-- @return A newly generated value, simplified from the previous value.
function Gen:shrink(prev)
  return self.shrink_func(prev)
end

return Gen

