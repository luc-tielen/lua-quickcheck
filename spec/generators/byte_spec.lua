local random = require 'src.random'
local byte = require 'src.generators.byte'
local r = require 'src.report'
local p = require 'src.property'
local property = p.property
local lqc = require 'src.quickcheck'

local function is_byte(value)
  return type(value) == 'number' 
          and value % 1 == 0 
          and value >= 0x00 
          and value <= 0xff
end

local function do_setup()
  random.seed()
  lqc.properties = {}
  r.report = function() end
end


describe('byte generator module', function()
  before_each(do_setup)

  describe('pick function', function()
    it('should pick a byte', function()
      local spy_check = spy.new(function(x) return is_byte(x) end)
      property 'byte() should pick a byte' {
        generators = { byte() },
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
      property 'byte() should converge to 0' {
        generators = { byte() },
        check = function(x)
          return not is_byte(x)  -- always fails!
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

