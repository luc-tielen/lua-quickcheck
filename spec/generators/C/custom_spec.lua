local random = require 'lqc.random'
local r = require 'lqc.report'
local property = require 'lqc.property'
local lqc = require 'lqc.quickcheck'
local int = require 'lqc.generators.int'

ffi.cdef [[
  struct point { uint32_t x; uint32_t y; };
  bool point_add(struct point* a, struct point* b, struct point* c_out);
]]
local point = ffi.metatype('struct point', {})
local clib = ffi.load 'fixtures'


local function do_setup()
  random.seed()
  lqc.init(100, 100)
  lqc.properties = {}
  r.report = function() end
end


describe('Basic usage of properties to test custom structs in C', function()
  before_each(do_setup)

  it('should be possible to verify C structs and their corresponding functions', function()
    local spy_check = spy.new(function(x1, y1, x2, y2)
      local a = point(x1, y1)
      local b = point(x2, y2)
      local c_out = point()
      local result = clib.point_add(a, b, c_out)
      return result and c_out.x == x1 + x2 and c_out.y == y1 + y2
    end)
    property 'C structs behaviour' {
      generators = { int(100), int(100), int(100), int(100) },
      check = spy_check
    }
    lqc.check()
    assert.spy(spy_check).was.called(lqc.numtests)
  end)

  it('should be possible to shrink properties with custom C structs', function()
    local shrunk_value_x, shrunk_value_y
    r.report_failed_property = function(_, _, shrunk_vals)
      shrunk_value_x = shrunk_vals[1]
      shrunk_value_y = shrunk_vals[2]
    end
    property 'C structs can also be shrunk to simpler inputs (indirectly)' {
      generators = { int(10), int(10) },
      check = function(x, y)
        local p = point(x, y)
        return clib.point_add(p, p, nil)  -- always fails
      end
    }
    for _ = 1, 10 do
      shrunk_value_x, shrunk_value_y = nil, nil
      lqc.check()
      assert.equal(0, shrunk_value_x)
      assert.equal(0, shrunk_value_y)
    end
  end)
end)

