local lqc_gen = require 'lqc.lqc_gen'
local tbl = require 'lqc.generators.table'
local int = require 'lqc.generators.int'
local float = require 'lqc.generators.float'
local str = require 'lqc.generators.string'
local bool = require 'lqc.generators.bool'


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

