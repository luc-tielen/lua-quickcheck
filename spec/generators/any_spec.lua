local random = require 'lqc.random'
local any = require 'lqc.generators.any'
local r = require 'lqc.report'
local property = require 'lqc.property'
local lqc = require 'lqc.quickcheck'

local function do_setup()
  random.seed()
  lqc.init(100, 100)
  lqc.properties = {}
  r.report = function() end
end

local function is_any(x)
  local t = type(x)
  return t == 'table'
      or t == 'string'
      or t == 'number'
      or t == 'boolean'
end

describe('any generator module', function()
  before_each(do_setup)

  describe('pick function', function()
    it('should pick "anything" from list of Lua types', function()
      local spy_check = spy.new(function(x) return is_any(x) end)
      property 'any() should pick "any" value' {
        generators = { any() },
        check = spy_check
      }

      lqc.check()
      assert.spy(spy_check).was.called(lqc.numtests)
    end)
  end)

  describe('shrink function', function()
    it('should shrink the generated value properly', function()
      property 'any() should shrink to a simpler value' {
        generators = { any(10) },
        check = function(x)
          return not is_any(x)
        end
      }

      for _ = 1, 30 do
        r.report_failed_property = spy.new(function() end)
        lqc.check()
        assert.spy(r.report_failed_property).was.called(1)
        -- TODO shrink test -> how to check values shrunk properly..
      end
    end)
  end)
end)

