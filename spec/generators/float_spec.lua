local random = require 'lqc.random'
local float = require 'lqc.generators.float'
local r = require 'lqc.report'
local property = require 'lqc.property'
local lqc = require 'lqc.quickcheck'

local function is_float(value)
  return type(value) == 'number'
    and value % 1 ~= 0
end

-- checks if x is in -1..0 if negative or 0..1 if positive
local function close_to_zero(x)
  local is_positive = x >= 0
  return is_positive and x < 1
                      or x > -1
end

local function do_setup()
  random.seed()
  lqc.init(100, 100)
  lqc.properties = {}
  r.report = function() end
end

-- TODO rename to real!

describe('float generator module', function()
  before_each(do_setup)

  describe('pick function', function()
    it('should pick a float', function()
      local spy_check = spy.new(function(x) return is_float(x) end)
      property 'float() should pick a float' {
        generators = { float() },
        check = spy_check
      }
      lqc.check()
      assert.spy(spy_check).was.called(lqc.numtests)
    end)
  end)

  describe('shrink function', function()
    it('should converge to 0.0', function()
      local shrunk_value
      r.report_failed_property = function(_, _, shrunk_vals)
        shrunk_value = shrunk_vals[1]
      end
      property 'float() should converge to 0.0' {
        generators = { float() },
        check = function(x) 
          return not is_float(x) -- always fails!
        end
      }

      for _ = 1, 100 do
        shrunk_value = nil
        lqc.check()
        assert.is_true(close_to_zero(shrunk_value))
      end
    end)
  end)
end)

