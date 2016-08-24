local Gen = require 'lqc.generator'
local random = require 'lqc.random'

-- picks a random bool (true or false)
local function pick()
  return random.between(0, 1) == 0
end

-- bool() always shrinks to false
local function shrink(_)
  return false
end

-- Creates a new bool generator
local function new()
  return Gen.new(pick, shrink)
end

return new

