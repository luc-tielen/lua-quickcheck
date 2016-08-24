local reduce = require 'lqc.helpers.reduce'

describe('reduce function', function()
  local t1 = { 1, 2, 3, 4, 5 }
  local t2 = { 'abc', 'def' }
  local function f1(elem, acc)
    return elem + acc
  end
  local function f2(elem, acc)
    return acc .. elem
  end

  it('should reduce a collection to a single result', function()
    local expected_sum = 15
    assert.equal(expected_sum, reduce(t1, 0, f1))
    assert.equal(expected_sum + 5, reduce(t1, 5, f1))

    local expected_str = 'abcdef'
    assert.equal(expected_str, reduce(t2, '', f2))
    assert.equal('012345' .. expected_str, reduce(t2, '012345', f2))
  end)

  it('should keep initial table untouched', function()
    reduce(t1, 0, f1)
    reduce(t2, '', f2)
    assert.same(t1, { 1, 2, 3, 4, 5 })
    assert.same(t2, { 'abc', 'def' })
  end)
end)

