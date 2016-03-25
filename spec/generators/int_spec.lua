local random = require 'src.random'
local int = require 'src.generators.int'

local function is_integer(value)
  return type(value) == 'number' and value % 1 == 0
end

-- TODO this should be tested with properties..
describe('int generator module', function()
  random.seed()

  describe('pick function', function()
    it('should pick an integer', function()
      local number = int()
      for _ = 1, 100 do
        local x = number:pick()
        assert.is_true(is_integer(x))
      end
    end)

    it('should pick an integer between 0 and X if only max is specified', function()
      local max = 10
      local number = int(max)
      for _ = 1, 100 do
        local x = number:pick()
        assert.is_true(x >= 0)
        assert.is_true(x <= max)
      end
    end)

    it('should pick an integer between X and Y if max and min are specified', function()
      local min, max = -5, 10
      local number = int(min, max)
      for _ = 1, 100 do
        local x = number:pick()
        assert.is_true(x >= min)
        assert.is_true(x <= max)
      end
    end)
  end)

  describe('shrink function', function()
    it('should converge to 0', function()
      local number = int()

      for _ = 1, 10, 1 do
        local x1 = number:pick()
        for _ = 1, 100, 1 do
          if x1 == 0 then break end
          local x2 = number:shrink(x1)
          if x1 > 0 then
            assert.is_true(x2 < x1 or x2 == 0)
          else
            assert.is_true(x2 > x1 or x2 == 0)
          end
          x1 = x2
        end
      end
    end)
  end)
end)

