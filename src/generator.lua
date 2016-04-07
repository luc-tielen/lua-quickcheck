local Gen = {}
local Gen_mt = { __index = Gen }

function Gen.new(pick_func, shrink_func)
  local Generator = {
    pick_func = pick_func,
    shrink_func = shrink_func,
  }

  return setmetatable(Generator, Gen_mt)
end

function Gen:pick(numtests)
  return self.pick_func(numtests)
end

function Gen:shrink(prev)
  return self.shrink_func(prev)
end

return Gen

