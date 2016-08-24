local gen = require 'lqc.generator'


describe('generator module', function()
  local function test_pick() return 9000 end
  local function test_shrink(prev) return prev + 1 end
  local spy_pick = spy.new(test_pick)
  local spy_shrink = spy.new(test_shrink)

  local g = gen.new(spy_pick, spy_shrink)

  describe('pick', function()
    it('should use the underlying pick function', function()
      local output = g:pick()
      assert.spy(spy_pick).was.called()
      assert.same(9000, output)
    end)
  end)
  describe('shrink', function()
    it('should use the underlying shrink function', function()
      local input = 1337
      local output = g:shrink(input)
      assert.spy(spy_shrink).was.called()
      assert.same(input + 1, output) 
    end)
  end)
end)

