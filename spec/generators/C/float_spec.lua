local random = require 'src.random'
local property = require 'src.property'
local lqc = require 'src.quickcheck'
local r = require 'src.report'
local double = require 'src.generators.float'
local float = double

local ffi = require 'ffi'
ffi.cdef [[
  float flt_add(float a, float b);
  double dbl_add(double a, double b);
]]
local clib = ffi.load 'fixtures'


local function do_setup()
  random.seed()
  lqc.properties = {}
  r.report = function() end
end


describe('double precision value generator for C functions', function()
  before_each(do_setup)

  it('should be possible to pick doubles', function()
    local spy_check = spy.new(function(a, b)
      return clib.dbl_add(a, b) == clib.dbl_add(b, a)
    end)
    property 'double() should pick a double' {
      generators = { double(), double() },
      check = spy_check
    }
    lqc.check()
    assert.spy(spy_check).was.called(lqc.iteration_amount)
  end)

  it('should be possible to pick floats', function()
    local spy_check = spy.new(function(a, b)
      return clib.flt_add(a, b) == clib.flt_add(b, a)
    end)
    property 'float() should pick a float' {
      generators = { float(), float() },
      check = spy_check
    }
    lqc.check()
    assert.spy(spy_check).was.called(lqc.iteration_amount)
  end)
end)

