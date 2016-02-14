local map = require 'src.functional.map'

describe('map function', function()
  it('should apply a function to all elements in the collection', function()
    local t1 = { 1, 2, 3, 4, 5 }
    local function f1(value)
      return value * 2
    end
    local expected1 = { 2, 4, 6, 8, 10 }
    assert.same(expected1, map(t1, f1))
    
    local t2 = { 'abc', 'def' }
    local function f2(value)
      return string.repr(value, 3)
    end
    local expected2 = { 'abcabcabc', 'defdefdef' }
  end)
end)

