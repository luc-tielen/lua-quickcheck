local random = require 'src.random'
local r = require 'src.report'
local p = require 'src.property'
local property = p.property
local lqc_gen = require 'src.lqc_gen'
local lqc = require 'src.quickcheck'

local function do_setup()
  random.seed()
  lqc.properties = {}
  r.report = function() end
end


describe('choose', function()
  before_each(do_setup)

  it('chooses a number between min and max', function()
    local min1, max1 = 569, 1387
    local spy_check_pos = spy.new(function(x) 
      return x >= min1 and x <= max1
    end)
    property 'chooses a number between min and max (positive integers)' {
      generators = { lqc_gen.choose(min1, max1) },
      check = spy_check_pos
    }

    local min2, max2 = -1337, -50
    local spy_check_neg = spy.new(function(x) 
      return x >= min2 and x <= max2
    end)
    property 'chooses a number between min and max (negative integers)' {
      generators = { lqc_gen.choose(min2, max2) },
      check = spy_check_neg
    }

    lqc.check()
    assert.spy(spy_check_pos).was.called(lqc.iteration_amount)
    assert.spy(spy_check_neg).was.called(lqc.iteration_amount)
  end)

  it('shrinks the generated value towards the value closest to 0', function()
    local min1, max1 = 5, 10
    local shrunk_value1 = nil
    r.report_failed = function(_, _, shrunk_vals)
      shrunk_value1 = shrunk_vals[1]
    end
    property 'shrinks the generated value towards min value (positive integers)' {
    generators = { lqc_gen.choose(min1, max1) },
      check = function(x)
        return x < min1  -- always false
      end
    }

    lqc.check()
    assert.same(min1, shrunk_value1)

    lqc.properties = {}
    local min2, max2 = -999, -333
    local shrunk_value2 = nil
    r.report_failed = function(_, _, shrunk_vals)
      shrunk_value2 = shrunk_vals[1]
    end
    property 'shrinks the generated value towards min value (negative integers)' {
      generators = { lqc_gen.choose(min2, max2) },
      check = function(x)
        return x < min2  -- always false
      end
    }

    lqc.check()
    assert.same(max2, shrunk_value2)
  end)
end)

