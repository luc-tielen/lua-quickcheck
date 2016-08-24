local Gen = require 'lqc.generator'
local int = require 'lqc.generators.int'

local lowest_ascii_value = 32    -- 'space'
local highest_ascii_value = 126  -- '~'
local int_gen = int(lowest_ascii_value, highest_ascii_value)
local space = string.char(lowest_ascii_value)


local function char_pick()
  return string.char(int_gen:pick_func())
end

local function char_shrink(prev)
  if string.byte(prev) <= lowest_ascii_value then
    return space
  end
  return string.char(string.byte(prev) - 1)
end

-- Generates an ASCII - char (no 'special' characters such as NUL, NAK...)
local function char()
  return Gen.new(char_pick, char_shrink)
end

return char

