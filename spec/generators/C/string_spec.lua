local random = require 'lqc.random'
local r = require 'lqc.report'
local property = require 'lqc.property'
local lqc = require 'lqc.quickcheck'
local str = require 'lqc.generators.string'

ffi.cdef [[
  const char* str_add(const char* const a, const char* const b); 
]]
local clib = ffi.load 'fixtures'


local function do_setup()
  random.seed()
  lqc.init(100, 100)
  lqc.properties = {}
  r.report = function() end
end


describe('Basic usage of properties to test strings in C', function()
  before_each(do_setup)

  it('should be possible to test properties that make use of C strings', function()
    local spy_check = spy.new(function(a, b)
      return a .. b == ffi.string(clib.str_add(a,b))
    end)
    property 'C string property' {
      generators = { str(3), str(3) },
      check = spy_check
    }
    lqc.check()
    assert.spy(spy_check).was.called(lqc.numtests)
  end)

  it('should be possible to shrink properties with C strings #jit_only', function()
    local shrunk_value
    r.report_failed_property = function(_, _, shrunk_vals)
      shrunk_value = shrunk_vals[1]
    end
    property 'C strings can also be shrunk to simpler inputs' {
      generators = { str(1) },
      check = function(x)
        return clib.str_add(x, nil) ~= nil  -- always fails
      end
    }
    for _ = 1, 10 do
      shrunk_value = nil
      lqc.check()
      assert.equal(' ', shrunk_value)  -- string shrinks to all spaces..
    end
  end)
end)

