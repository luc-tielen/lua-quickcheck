local filter = require 'lqc.helpers.filter'

describe('filter function', function()
  local t1 = { 1, 2, 3, 4, 5 }
  local function f1(value)
    return value % 2 == 0
  end

  local t2 = { 'abc', 'defg' }
  local function f2(value)
    return #value == 3
  end


  it('should filter out elements for which predicate is false', function()
    local expected1 = { 2, 4 }
    assert.same(expected1, filter(t1, f1))
    local expected2 = { 'abc' }
    assert.same(expected2, filter(t2, f2))
  end)
  it('should keep initial table untouched', function()
    filter(t1, f1)
    filter(t2, f2)
    assert.same(t1, { 1, 2, 3, 4, 5 })
    assert.same(t2, { 'abc', 'defg' })
  end)
end)

