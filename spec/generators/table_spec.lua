local random = require 'lqc.random'
local tbl = require 'lqc.generators.table'
local r = require 'lqc.report'
local property = require 'lqc.property'
local lqc = require 'lqc.quickcheck'

local function is_table(value)
  return type(value) == 'table'
end

local function do_setup()
  random.seed()
  lqc.init(100, 100)
  lqc.properties = {}
  r.report = function() end
end

describe('table generator module', function()
  before_each(do_setup)

  describe('pick function', function()
    it('should pick an arbitrarily sized table with tbl()', function()
      local spy_check1 = spy.new(function(x) 
        return is_table(x) and #x <= lqc.numtests
      end)
      property 'table() should pick a table' {
        generators = { tbl() },
        check = spy_check1
      }
      lqc.check()
      assert.spy(spy_check1).was.called(lqc.numtests)
      lqc.properties = {}

      local num_tests = 10
      local spy_check2 = spy.new(function(x) 
        return is_table(x) and #x <= num_tests
      end)
      property 'table() should pick a table of size <= numtests' {
        generators = { tbl() },
        check = spy_check2,
        numtests = num_tests
      }
      lqc.check()
      assert.spy(spy_check2).was.called(num_tests)
    end)
    
    it('should pick a table of specific size with tbl(size)', function()
      local size = 3
      local spy_check1 = spy.new(function(x) 
        return is_table(x) and #x == size
      end)
      property 'table(size) should pick a table with that specific size' {
        generators = { tbl(size) },
        check = spy_check1
      }
      lqc.check()
      assert.spy(spy_check1).was.called(lqc.numtests)
      lqc.properties = {}

      local num_tests = 10
      local spy_check2 = spy.new(function(x) 
        return is_table(x) and #x == size
      end)
      property 'table(size) should pick a table with that specific size' {
        generators = { tbl(size) },
        check = spy_check2,
        numtests = num_tests
      }
      lqc.check()
      assert.spy(spy_check2).was.called(num_tests)
    end)
  end)

  describe('shrink function', function()
    it('should shrink table values and size when no size specified', function()
      local shrunk_value, generated_value
      r.report_failed_property = function(_, generated_vals, shrunk_vals)
        generated_value = generated_vals[1]
        shrunk_value = shrunk_vals[1]
      end
      property 'table() should shrink to smaller and simpler string' {
        generators = { tbl() },
        check = function(x)
          return not is_table(x)  -- always fails!
        end
      }

      for _ = 1, 30 do
        shrunk_value, generated_value = nil, nil
        lqc.check()
        assert.is_true(#shrunk_value <= #generated_value)
        -- figure out way to compare values? if possible at all..
      end
    end)

    it('should only shrink table values when a size is specified', function()
      local size = 5
      local shrunk_value
      r.report_failed_property = function(_, _, shrunk_vals)
        shrunk_value = shrunk_vals[1]
      end

      property 'table(size) should shrink to simpler table of same size' {
        generators = { tbl(size) },
        check = function(x)
          return not is_table(x)  -- always fails!
        end
      }

      for _ = 1, 30 do
        shrunk_value = nil
        lqc.check()
        assert.is_equal(size, #shrunk_value)
        -- TODO check shrinking, value per value
      end
    end)
  end)
end)

