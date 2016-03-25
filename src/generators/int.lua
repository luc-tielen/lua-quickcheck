local Gen = require 'src.generator'
local random = require "src.random"

local limit = 2 ^ 32

local function pick(min, max)
  local function do_pick()
    return random.between(min, max)
  end
  return do_pick
end

local function shrink(previous)
  -- TODO improve this function after property has been introduced..
  if previous == 0 then return 0 end
  if previous > 0 then return math.floor(previous / 2) end
  return math.ceil(previous / 2)
end

local function integer_between(min, max)
  return Gen.new(pick(min, max), shrink)
end

local function positive_integer(max)
  return Gen.new(pick(0, max), shrink)
end

local function integer()
  local value = limit / 2
  return Gen.new(pick(value - limit, value), shrink)
end

local function new(nr1, nr2) --(max, min)
  if nr1 and nr2 then return integer_between(nr1, nr2) end
  if nr1 then return positive_integer(nr1) end
  return integer()
end

return new

