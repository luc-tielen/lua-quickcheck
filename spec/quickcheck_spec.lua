local lqc = require 'src.quickcheck'
local p = require 'src.property'


describe('quickcheck', function()
  describe('check function', function()
    it('should check every property', function()
      local x, amount = 0, 5
      for i = 1, amount do
        p.property('test property', function()
          x = x + 1
        end)
      end

      lqc.check()
      local expected = amount
      assert.equal(expected, x)
    end)
  end)
end)

