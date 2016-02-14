
local gen = {}
local gen_mt = { __index = gen }

function gen.new(pick_func, shrink_func)
  local generator = {
    pick_func = pick_func,
    shrink_func = shrink_func
  }
  return setmetatable(generator, gen_mt)
end

function gen:pick()
  return self.pick_func()
end

function gen:shrink(prev)
  return self.shrink_func(prev)
end

return gen

