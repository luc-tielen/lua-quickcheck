local int = require 'src.generators.int'

local function byte()
  return int(0, 255)
end

return byte

