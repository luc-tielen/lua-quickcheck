
--- Module for generating a bool randomly.
-- @classmod lqc.generators.bool
-- @alias new

local Gen = require 'lqc.generator'
local random = require 'lqc.random'

--- Picks a random bool
-- @return true or false
local function pick()
  return random.between(0, 1) == 0
end

--- Shrinks down a bool (always shrinks to false)
local function shrink(_)
  return false
end

--- Creates a new bool generator
-- @return A generator object for randomly generating bools.
local function new()
  return Gen.new(pick, shrink)
end

return new

