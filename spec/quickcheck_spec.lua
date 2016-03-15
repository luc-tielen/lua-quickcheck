local lqc = require 'src.quickcheck'
local r = require 'src.report'
local p = require 'src.property'
local property = p.property

local function clear_properties()
  lqc.properties = {}
  r.report = function(_) end
end

local function failing_gen()
  local gen = {}
  function gen.pick()
    return -10
  end
  function gen.shrink(prev)
    return prev + 1
  end
  return gen
end


describe('quickcheck', function()
  before_each(clear_properties)

  describe('check function', function()
    it('should check every successful property X amount of times', function()
      local x, prop_amount = 0, 5
      for _ = 1, prop_amount do
        property 'test property' {
          generators = {},
          check = function()
            x = x + 1
            return true
          end
        }
      end

      lqc.check()
      local expected = prop_amount * 100
      assert.equal(expected, x)
    end)

    it('should continue to check if a constraint of property is not met', function()
      local x = 0
      property 'test property' {
        generators = {},
        check = function() return true end,
        implies = function()
          x = x + 1
          return false
        end
      }

      lqc.check()
      local expected = lqc.iteration_amount
      assert.equal(expected, x)
    end)

    it('should stop checking a property after a failure', function()
      local x, iterations = 0, 10
      property 'test property' {
        generators = {},
        check = function()
          x = x + 1
          return x < iterations
        end
      }
      lqc.check()
      local expected = iterations
      assert.equal(expected, x)
    end)
  end)

  describe('shrink function', function()
    it('should try to reduce failing properties to a simpler form (0 params)', function()
      local generated_values
      local shrunk_values
      r.report_failed = function(_, generated_vals, shrunk_vals)
        generated_values = generated_vals
        shrunk_values = shrunk_vals
      end
      property 'failing property' {
        generators = {},
        check = function()
          return false
        end
      }
      lqc.check()
      assert.same(generated_values, {})
      assert.same(shrunk_values, {})
    end)

    it('should try to reduce failing properties to a simpler form (1 param)', function()
      local generated_values
      local shrunk_values
      r.report_failed = function(_, generated_vals, shrunk_vals)
        generated_values = generated_vals
        shrunk_values = shrunk_vals
      end
      property 'failing property' {
        generators = { failing_gen() },
        check = function(x)
          return x >= 0
        end
      }
      lqc.check()
      assert.same({ -10 }, generated_values)
      assert.same({ -1 }, shrunk_values)
    end)

    it('should try to reduce failing properties to a simpler form (2 params)', function()
      local generated_values
      local shrunk_values
      r.report_failed = function(_, generated_vals, shrunk_vals)
        generated_values = generated_vals
        shrunk_values = shrunk_vals
      end
      property 'failing property' {
        generators = { failing_gen(), failing_gen() },
        check = function(x, y)
          return x > y
        end
      }
      lqc.check()
      -- TODO improve this test..
      assert.same({ -10, -10 }, generated_values)
      assert.equal(shrunk_values[1], shrunk_values[2])
    end)
  end)
end)

