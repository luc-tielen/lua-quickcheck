local random = require 'lqc.random'
local r = require 'lqc.report'
local property = require 'lqc.property'
local lqc = require 'lqc.quickcheck'
local lqc_gen = require 'lqc.lqc_gen'

ffi.cdef [[
  uint8_t add(uint8_t a, uint8_t b);
  bool less_than_zero(int x);
]]
local clib = ffi.load 'fixtures'


local function do_setup()
  random.seed()
  lqc.init(100, 100)
  lqc.properties = {}
  r.report = function() end
end


describe('Basic usage of properties to test C code', function()
  before_each(do_setup)

  it('should be possible to verify C functions', function()
    local spy_check = spy.new(function(a, b)
      return a + b == clib.add(a, b)
    end)
    property 'C add function' {
      generators = { lqc_gen.choose(10, 20), lqc_gen.choose(0, 200) },
      check = spy_check
    }
    lqc.check()
    assert.spy(spy_check).was.called(lqc.numtests)
  end)

  it('should be possible to shrink an incorrect C property', function()
    local min_val = 1
    local shrunk_value
    r.report_failed_property = function(_, _, shrunk_vals)
      shrunk_value = shrunk_vals[1]
    end
    property 'C functions can also be shrank to simpler inputs' {
      generators = { lqc_gen.choose(min_val, 10) },
      check = function(x)
        return clib.less_than_zero(x)  -- always fails
      end
    }
    for _ = 1, 10 do
      shrunk_value = nil
      lqc.check()
      assert.equal(min_val, shrunk_value)
    end
  end)
end)

