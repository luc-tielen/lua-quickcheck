local lqc = require 'lqc.quickcheck'
local r = require 'lqc.report'
local property = require 'lqc.property'

local function setup_property_engine()
  lqc.init(1, 100)
  lqc.properties = {}
  r.report = function(_) end
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
    assert.spy(report_spy).was.called(2 * lqc.numtests)
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
    assert.spy(report_spy).was.called(2 * lqc.numtests)
  end)

  it('should report failure when a a property fails', function()
    local report_spy = spy.new(r.report_failed_property)
    r.report_failed_property = report_spy
    
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

