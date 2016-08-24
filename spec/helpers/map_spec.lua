local map = require 'lqc.helpers.map'

describe('map function', function()
  local t1 = { 1, 2, 3, 4, 5 }
  local function f1(value)
    return value * 2
  end

  local t2 = { 'abc', 'def' }
  local function f2(value)
    return string.rep(value, 3)
  end


  it('should apply a function to all elements in the collection', function()
    local expected1 = { 2, 4, 6, 8, 10 }
    assert.same(expected1, map(t1, f1))
    local expected2 = { 'abcabcabc', 'defdefdef' }
    assert.same(expected2, map(t2, f2))
  end)
  it('should keep initial table untouched', function()
    map(t1, f1)
    map(t2, f2)
    assert.same(t1, { 1, 2, 3, 4, 5 })
    assert.same(t2, { 'abc', 'def' })
  end)
end)

