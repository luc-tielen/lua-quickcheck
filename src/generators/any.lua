local lqc_gen = require 'src.lqc_gen'
local tbl = require 'src.generators.table'
local int = require 'src.generators.int'
local float = require 'src.generators.float'
local str = require 'src.generators.string'
local bool = require 'src.generators.bool'


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

