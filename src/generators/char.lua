local int = require 'src.generators.int'

local lowest_ascii_value = 32    -- 'space'
local highest_ascii_value = 126  -- '~'

local function char_shrink(prev)
  return prev - 1
end

-- Generates an ASCII - char (no 'special' characters such as NUL, NAK...)
local function char()
  local gen = int(lowest_ascii_value, highest_ascii_value)
  gen.shrink_func = char_shrink
  return gen
end

return char

