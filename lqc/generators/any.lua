
--- Module for generating 'any' random value.
-- @lqc.generators.any
-- @alias new

local lqc_gen = require 'lqc.lqc_gen'
local tbl = require 'lqc.generators.table'
local int = require 'lqc.generators.int'
local float = require 'lqc.generators.float'
local str = require 'lqc.generators.string'
local bool = require 'lqc.generators.bool'


--- Creates a new generator that can generate a table, string, int, float or bool.
-- @param optional_samplesize Amount of times the property is tested, used to guide
--        the randomization process.
-- @return generator that can generate 1 of the previously mentioned types in
--         the description
local function new(optional_samplesize)
  return lqc_gen.oneof {
    tbl(optional_samplesize),
    str(optional_samplesize),
    int(optional_samplesize),
    float(),
    bool()
 }
end

return new

