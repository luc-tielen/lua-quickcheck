local lqc = require 'src.quickcheck'
local p = require 'src.property'
local property = p.property


describe('quickcheck', function()
  describe('check function', function()
    it('should check every property', function()
      local x, amount = 0, 5
      for _ = 1, amount do
        property 'test property' {
          generators = {},
          check = function()
            x = x + 1
            return true
          end
        }
      end

      lqc.check()
      local expected = amount
      assert.equal(expected, x)
    end)
  end)
end)

