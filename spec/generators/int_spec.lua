local random = require 'src.random'
local int = require 'src.generators.int'

local r = require 'src.report'
local p = require 'src.property'
local property = p.property
local lqc = require 'src.quickcheck'

local function is_integer(value)
  return type(value) == 'number' and value % 1 == 0
end

local function do_setup()
  random.seed()
  lqc.properties = {}
  r.report = function() end
end

describe('int generator module', function()
  before_each(do_setup)

  describe('pick function', function()
    it('should pick an integer', function()
      local spy_check = spy.new(function(x) return is_integer(x) end)
      property 'int() should pick an integer' {
        generators = { int() },
        check = spy_check
      }
      lqc.check()
      assert.spy(spy_check).was.called(lqc.iteration_amount)
    end)

    it('should pick an integer between 0 and X if only max is specified', function()
      local max = 10
      local spy_check = spy.new(function(x)
        return is_integer(x) and (x >= 0) and (x <= max)
      end)
      property 'int(max) should pick integer X such that 0 <= X <= max' {
        generators = { int(max) },
        check = spy_check
      }
      lqc.check()
      assert.spy(spy_check).was.called(lqc.iteration_amount)
    end)

    it('should pick an integer between X and Y if max and min are specified', function()
      local min, max = -5, 10
      local spy_check = spy.new(function(x)
        return is_integer(x) and (x >= min) and (x <= max)
      end)
      property 'int(min, max) should pick integer X such that min <= X <= max' {
        generators = { int(min, max) },
        check = spy_check
      }
      lqc.check()
      assert.spy(spy_check).was.called(lqc.iteration_amount)
    end)
  end)

  describe('shrink function', function()
    it('should converge to 0', function()
      local shrunk_values
      r.report_failed = function(_, _, shrunk_vals)
        shrunk_values = shrunk_vals[1]
      end
      property 'int() should converge to 0' {
        generators = { int() },
        check = function(x)
          return not is_integer(x)  -- always fails!
        end
      }

      for _ = 1, 100 do
        shrunk_values = nil
        lqc.check()
        assert.equal(0, shrunk_values)
      end
    end)
  end)
end)

