local tbl = require 'lqc.generators.table'
local lqc = require 'lqc.quickcheck'
local property = require 'lqc.property'
local r = require 'lqc.report'
local random = require 'lqc.random'
local deep_copy = require 'lqc.helpers.deep_copy'


local function do_setup()
  random.seed()
  lqc.init(100, 100)
  lqc.properties = {}
  r.report = function() end
end


describe('deep_copy helper function', function()
  before_each(do_setup)

  it('it should create a deep copy for a (nested) table', function()
    local spy_check = spy.new(function(x)
      local y = deep_copy(x)
      assert.same(x, y)       -- contents should be the same
      assert.not_equal(x, y)  -- different addresses because y is a copy of x
      return true
    end)
    property 'deep_copy should make a copy of a nested table' {
      generators = { tbl() },
      check = spy_check
    }
    lqc.check()
    assert.spy(spy_check).was.called(lqc.numtests)
  end)

  it('should not be possible to modify the original by modifying the copy', function()
    local x = { 1, 2,  { a = 4 } }
    local y = deep_copy(x)
    for i = 1, #x do
      y[i] = 0
    end
    assert.not_same(x, y)
    assert.same({ 1, 2, { a = 4 } }, x)
    
    y = deep_copy(x)
    assert.same(x, y)

    y[3].a = 5
    assert.not_same(x, y)
    assert.same({ 1, 2, { a = 4 } }, x)
  end)
end)

