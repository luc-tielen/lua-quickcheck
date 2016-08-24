local random = require 'lqc.random'
local bool = require 'lqc.generators.bool'
local r = require 'lqc.report'
local property = require 'lqc.property'
local lqc = require 'lqc.quickcheck'

local function is_bool(x)
  return type(x) == 'boolean'
end

local function do_setup()
  random.seed()
  lqc.init(100, 100)
  lqc.properties = {}
  r.report = function() end
end


describe('boolean generator', function()
  before_each(do_setup) 
  
  describe('pick function', function()
    it('should pick a boolean', function()
      local spy_check = spy.new(function(x) return is_bool(x) end)
      property 'bool() should pick a boolean' {
        generators = { bool() },
        check = spy_check
      }
      lqc.check()
      assert.spy(spy_check).was.called(lqc.numtests)
    end)
  end)

  describe('shrink function', function()
    it('should shrink to false', function()
      local shrunk_value
      r.report_failed_property = function(_, _, shrunk_vals)
        shrunk_value = shrunk_vals[1]
      end
      property 'bool() generator shrinks to false' {
        generators = { bool() },
        check = function(x)
          return not is_bool(x)  -- always fails!
        end
      }
      for _ = 1, 10 do
        shrunk_value = nil
        lqc.check()
        assert.equal(false, shrunk_value)
      end
    end)
  end)
end)

