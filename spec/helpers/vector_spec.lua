local Vector = require 'lqc.helpers.vector'
local deep_copy = require 'lqc.helpers.deep_copy'


describe('vector datastructure', function()
  it('should be possible to initialize a vector (empty or with elements)', function()
    local v1 = Vector.new()
    local expected2 = { 'a', 'b', 'c' }
    local v2 = Vector.new(expected2)
    assert.same({}, v1:to_table())
    assert.same(expected2, v2:to_table())
  end)

  it('should be possible to add elements to the vector', function()
    local v = Vector.new()
    local expected = {}
    assert.same(expected, v:to_table())

    local values = { 1, 'a', { { 2 }, false } }
    for _, value in ipairs(values) do
      v:push_back(value)
      table.insert(expected, value)
      assert.same(expected, v:to_table())
    end
    assert.equal(false, pcall(function() v:push_back(nil) end))
  end)

  it('should be possible to replace elements in the vector', function()
    local v = Vector.new({ 1, 2, 3 })
    local function try_replace(idx, obj)
      local function do_replace()
        v:replace(idx, obj)
      end
      return do_replace
    end

    assert.is_false(pcall(try_replace(0, 'invalid')))
    assert.is_true(pcall(try_replace(1, 4)))
    assert.is_true(pcall(try_replace(2, 5)))
    assert.is_true(pcall(try_replace(3, 6)))
    assert.is_false(pcall(try_replace(4, 'invalid')))
    assert.same(v:to_table(), { 4, 5, 6 })
  end)

  it('should be possible to retrieve certain elements out of the vector', function()
    local value1, value2, value3 = 1, 'a', { { 2 }, false }
    local values = { value1, value2, value3 }
    local v = Vector.new(values)

    for i = 1, #values do
      local expected = values[i]
      assert.same(expected, v:get(i))
    end
  end)

  it('should be possible to append 2 vectors', function()
    local vec_a, vec_b = Vector.new(), Vector.new({ 1, 2, 3 })
    local vec_c, vec_d = Vector.new({ 'a', 'b' }), Vector.new()
    local vec_e, vec_f = Vector.new({ true, false }), Vector.new({ 'x', 'y', 'z' })
    assert.same({ 1, 2, 3 }, vec_a:append(vec_b):to_table())
    assert.same({ 'a', 'b' }, vec_c:append(vec_d):to_table())
    assert.same({ true, false, 'x', 'y', 'z' }, vec_e:append(vec_f):to_table())
  end)

  it('should be possible to get the size of the vector', function()
    local v = Vector.new()
    assert.equal(0, v:size())
    local values = { 1, 'a', { { 2 }, false } }
    for i = 1, #values do
      v:push_back(values[i])
      assert.equal(i, v:size())
    end

    for i = #values, 1, -1 do
      v:remove_index(i)
      assert.equal(i - 1, v:size())
    end
    assert.equal(0, v:size())
  end)

  it('should be possible to remove elements of the vector by value', function()
    local value1, value2, value3 = 1, 'a', { { 2 }, false }
    local values = { value1, value2, value3 }
    local v = Vector.new(values)

    v:remove(value2)
    assert.same(v:to_table(), { value1, value3 })
    v:remove(value1)
    assert.same(v:to_table(), { value3 })
    v:remove(value3)
    assert.same(v:to_table(), {})
    v:remove(value1)
    assert.same(v:to_table(), {})

    -- check if it removes by value for tables
    local value4 = { 1, 2, 3 }
    local v2 = Vector.new({ value4 })
    v2:remove(deep_copy(value4))
    assert.equal(0, v2:size())
  end)

  it('should be possible to remove elements of the vector by index', function()
    local value1, value2, value3 = 1, 'a', { { 2 }, false }
    local values = { value1, value2, value3 }
    local v = Vector.new(values)

    v:remove_index(2)
    assert.same(v:to_table(), { value1, value3 })
    v:remove_index(1)
    assert.same(v:to_table(), { value3 })
    v:remove_index(1)
    assert.same(v:to_table(), {})
    v:remove_index(3)
    assert.same(v:to_table(), {})
  end)

  it('should be possible to check if an element is in the container', function()
    local values_a = { 1, 2, 3, 4, 5 }
    local values_b = { 6, 7, 8, 9, 10 }
    local v = Vector.new(values_a)

    for i = 1, #values_a do
      assert.is_true(v:contains(values_a[i]))
    end
    for i = 1, #values_b do
      assert.is_false(v:contains(values_b[i]))
    end
  end)
end)

