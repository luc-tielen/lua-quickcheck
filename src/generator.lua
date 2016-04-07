local lqc = require 'src.quickcheck'  -- TODO split off iter amount into config module
local Gen = {}
local Gen_mt = { __index = Gen }

function Gen.new(pick_func, shrink_func)
  local Generator = {
    pick_func = pick_func,
    shrink_func = shrink_func,
    numtests = lqc.iteration_amount
  }

  return setmetatable(Generator, Gen_mt)
end

function Gen:pick()
  return self.pick_func(self.numtests)
end

function Gen:shrink(prev)
  return self.shrink_func(prev)
end

return Gen

