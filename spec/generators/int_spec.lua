local random = require 'lqc.random'
local int = require 'lqc.generators.int'
local r = require 'lqc.report'
local property = require 'lqc.property'
local lqc = require 'lqc.quickcheck'

local function is_integer(value)
  return type(value) == 'number' and value % 1 == 0
end

local function do_setup()
  random.seed()
  lqc.init(100, 100)
  lqc.properties = {}
  r.report = function() end
end

describe('int generator module', function()
  before_each(do_setup)

  describe('pick function', function()
    it('should pick an integer', function()
      local spy_check1 = spy.new(function(x)
        return is_integer(x)
           and x >= - lqc.numtests / 2
           and x <=   lqc.numtests / 2
      end)
      property 'int() should pick between +- sample_size / 2, pt 1' {
        generators = { int() },
        check = spy_check1
      }
      lqc.check()
      assert.spy(spy_check1).was.called(lqc.numtests)
      lqc.properties = {}

      local num_tests = 10
      local spy_check2 = spy.new(function(x)
        return is_integer(x)
           and x >= - num_tests / 2
           and x <=   num_tests / 2
      end)
      property 'int() should pick between +- sample_size / 2, pt 2' {
        generators = { int() },
        check = spy_check2,
        numtests = num_tests
      }
      lqc.check()
      assert.spy(spy_check2).was.called(num_tests)
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
      assert.spy(spy_check).was.called(lqc.numtests)
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
      assert.spy(spy_check).was.called(lqc.numtests)
    end)
  end)

  describe('shrink function', function()
    it('should converge to 0', function()
      local shrunk_values
      r.report_failed_property = function(_, _, shrunk_vals)
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

    it('should converge to 0 or closest value to 0 for int(min, max)', function()
      local shrunk_values
      r.report_failed_property = function(_, _, shrunk_vals)
        shrunk_values = shrunk_vals
      end
      property 'int() should converge to 1' {
        generators = { int(1, 1000), int(-1000, -1) },
        check = function(x, y)
          return not (is_integer(x) or is_integer(y))  -- always fails!
        end
      }

      for _ = 1, 100 do
        shrunk_values = nil
        lqc.check()
        assert.equal(1, shrunk_values[1])
        assert.equal(-1, shrunk_values[2])
      end
    end)
  end)

  it('should retry shrinking previous values if shrunk values are skipped', function()
    local shrunk_value
    r.report_failed_property = function(_, _, shrunk_vals)
      shrunk_value = shrunk_vals[1]
    end
    property 'shrinking when constraint is not met retries with previous values' {
      generators = { int(100) },
      check = function()
        return false  -- always fails
      end,
      implies = function(x)
        return x >= 1
      end
    }

    for _ = 1, 5 do
      shrunk_value = nil
      lqc.check()
      assert.equal(1, shrunk_value)
    end
  end)
end)

