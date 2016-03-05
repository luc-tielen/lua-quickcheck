local Gen = require 'src.generator'
local random = require "src.random"

local limit = 2 ^ 64  -- TODO check limit is correct..

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


local function new(max, min)
  -- TODO check defaults
  if not max then max = limit end
  if not min then min = 0 end
  return Gen.new(pick(min, max), shrink)
end

return new

