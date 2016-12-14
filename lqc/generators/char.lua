
--- Module for generating a random (ASCII) char (no 'special' characters such as NUL, NAK, ...)
-- @lqc.generators.char
-- @alias char

local Gen = require 'lqc.generator'
local int = require 'lqc.generators.int'

local lowest_ascii_value = 32    -- 'space'
local highest_ascii_value = 126  -- '~'
local int_gen = int(lowest_ascii_value, highest_ascii_value)
local space = string.char(lowest_ascii_value)


-- Generates a random character (ASCII value between 'space' and '~'
-- @return randomly chosen char (string of length 1)
local function char_pick()
  return string.char(int_gen:pick_func())
end


--- Shrinks down a previously generated char to a simpler value. Shrinks
--  towards the 'space' ASCII character.
-- @param prev previously generated char value
-- @return shrunk down char value
local function char_shrink(prev)
  if string.byte(prev) <= lowest_ascii_value then
    return space
  end
  return string.char(string.byte(prev) - 1)
end


--- Creates a generator for ASCII-chars
-- @return generator that can randomly create ASCII values
local function char()
  return Gen.new(char_pick, char_shrink)
end

return char

