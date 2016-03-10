local lqc = require 'src.quickcheck'
local r = require 'src.report'
local p = require 'src.property'
local property = p.property

local function setup_property_engine()
  lqc.iteration_amount = 1
  lqc.properties = {}
  r.report_success = function() end
  r.report_skipped = function() end
  r.report_failed = function() end
end

describe('reporting of results', function()
  before_each(setup_property_engine)

  it('should report success for each successful test in a property', function()
    local report_spy = spy.new(r.report_success)
    r.report_success = report_spy
    
    property 'test property' {
      generators = {},
      check = function()
        return true
      end
    }

    property 'test property #2' {
      generators = {},
      check = function()
        return 1 + 1 == 2
      end
    }

    lqc.check()
    assert.spy(report_spy).was.called(2 * lqc.iteration_amount)
  end)

  it('should report skipped for a generated set of inputs that dit not meat the constraints', function()
    local report_spy = spy.new(r.report_skipped)
    r.report_skipped = report_spy

    property 'test property' {
      generators = {},
      check = function()
        return true
      end,
      implies = function()
        return false
      end
    }

    property 'test property #2' {
      generators = {},
      check = function()
        return 1 + 1 == 2
      end,
      implies = function()
        return -1 > 0
      end
    }

    lqc.check()
    assert.spy(report_spy).was.called(2 * lqc.iteration_amount)
  end)

  it('should report failure when a a property fails', function()
    local report_spy = spy.new(r.report_failed)
    r.report_failed = report_spy
    
    property 'test property' {
      generators = {},
      check = function()
        return false
      end
    }

    property 'test property #2' {
      generators = {},
      check = function()
        return -1337 > 0
      end
    }

    lqc.check()
    assert.spy(report_spy).was.called(2)
  end)
end)
