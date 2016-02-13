random = require 'src.random'
int = require 'src.generators.int'

-- TODO these are best tested with properties..

local function is_integer(int)
  return type(int) == 'number' and int % 1 == 0
end

describe('int generator module', function()
  random.seed()

  describe('pick function', function()
    it('should pick an integer', function()
      for i = 1, 100, 1 do
        local x = int.pick()
        assert.is_true(is_integer(x))
      end
    end)
  end)
  describe('shrink function', function()
    it('should converge to 0', function()
      for j = 1, 10, 1 do
        local x1 = int.pick()
        for i = 1, 100, 1 do
          if x1 == 0 then break end
          local x2 = int.shrink(x1)
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

