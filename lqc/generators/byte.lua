
--- Module for generating bytes randomly.
--  A byte is an integer with value between 0 - 255 (inclusive)
-- @classmod lqc.generators.byte
-- @alias byte

local int = require 'lqc.generators.int'

-- Creates a new byte generator
-- @return generator for generating random byte values
local function byte()
  return int(0, 255)
end

return byte

