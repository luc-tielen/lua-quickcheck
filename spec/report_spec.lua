local lqc = require 'src.quickcheck'
local r = require 'src.report'
local p = require 'src.property'
local property = p.property

local function setup_property_engine()
  lqc.iteration_amount = 1
  lqc.properties = {}
end

describe('reporting of results', function()
  before_each(setup_property_engine)

  -- TODO figure out how to capture stdout for more thorough testing..

  it('should report success for each successful test in a property', function()
    local x = 0
    r.report_success = function()
      x = x + 1
    end
    
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
    assert.equal(2, x)
  end)

  it('should report skipped for a generated set of inputs that dit not meat the constraints', function()
    local x = 0
    r.report_skipped = function()
      x = x + 1
    end
    
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
    assert.equal(2, x)
  end)

  it('should report failure when a a property fails', function()
    local x = 0
    r.report_failed = function()
      x = x + 1
    end
    
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
    assert.equal(2, x)
  end)
end)

