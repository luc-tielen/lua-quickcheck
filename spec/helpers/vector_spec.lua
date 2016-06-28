local Vector = require 'src.helpers.vector'


describe('vector datastructure', function()
  it('should be possible to initialize a vector (empty or with elements)', function()
    local v1 = Vector.new()
    local expected2 = { "a", "b", "c" }
    local v2 = Vector.new(expected2)
    assert.same({}, v1:to_table())
    assert.same(expected2, v2:to_table())
  end)

  it('should be possible to add elements to the vector', function()
    local v = Vector.new()
    local expected = {}
    assert.same(expected, v:to_table())

    local values = { 1, "a", { { 2 }, false } }
    for _, value in ipairs(values) do
      v:push_back(value)
      table.insert(expected, value)
      assert.same(expected, v:to_table())
    end
    assert.equal(false, pcall(function() v:push_back(nil) end))  
    -- TODO add multiple elements at once?
  end)

  it('should be possible to retrieve certain elements out of the vector', function()
    local value1, value2, value3 = 1, "a", { { 2 }, false }
    local values = { value1, value2, value3 }
    local v = Vector.new(values)

    for i = 1, #values do
      local expected = values[i]
      assert.same(expected, v:get(i))
    end
  end)

  it('should be possible to remove elements of the vector', function()
    local value1, value2, value3 = 1, "a", { { 2 }, false }
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
  end)
end)

