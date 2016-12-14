local random = require 'lqc.random'
local str = require 'lqc.generators.string'
local r = require 'lqc.report'
local property = require 'lqc.property'
local lqc = require 'lqc.quickcheck'
local reduce = require 'lqc.helpers.reduce'

local function is_string(s)
  return type(s) == 'string'
end

local function string_sum(s)
  local numbers = { string.byte(s, 1, #s) }
  return reduce(numbers, 0, function(x, acc) return x + acc end)
end

local function do_setup()
  random.seed()
  lqc.init(100, 100)
  lqc.properties = {}
  r.report = function() end
end


describe('string generator module', function()
  before_each(do_setup)

  describe('pick function', function()
    it('should pick an arbitrary length string if size not specified', function()
      local results = {}
      local spy_check = spy.new(function(x)
        table.insert(results, #x)
        return is_string(x)
      end)

      property 'string() should pick an arbitrary sized string' {
        generators = { str() },
        check = spy_check
      }
      lqc.check()
      assert.spy(spy_check).was.called(lqc.numtests)

      -- If all lengths were equal:
      -- sum of lengths = first element times numtests
      local sum_lengths = reduce(results, 0, function(x, acc) return x + acc end)
      assert.not_equal(results[1] * lqc.numtests, sum_lengths)
    end)

    it('should pick a fixed size string if size is specified', function()
      local length = 3
      local spy_check = spy.new(function(x)
        return is_string(x) and #x == length
      end)

      property 'string(len) should pick a fixed length string (size len)' {
        generators = { str(length) },
        check = spy_check
      }
      lqc.check()
      assert.spy(spy_check).was.called(lqc.numtests)
    end)
  end)

  describe('shrink function', function()
    it('should shrink to a smaller string if no size specified', function()
      local generated_value, shrunk_value
      r.report_failed_property = function(_, generated_vals, shrunk_vals)
        generated_value = generated_vals[1]
        shrunk_value = shrunk_vals[1]
      end

      property 'string() should shrink to smaller and simpler string' {
        generators = { str() },
        check = function(x)
          return not is_string(x) -- always fails!
        end
      }

      for _ = 1, 100 do
        shrunk_value, generated_value = nil, nil
        lqc.check()
        assert.is_true(#shrunk_value <= #generated_value)
        assert.is_true(string_sum(shrunk_value) <= string_sum(generated_value))
      end
    end)

    it('should shrink to a simpler string of same size if size specified', function()
      local length = 5
      local generated_value, shrunk_value
      r.report_failed_property = function(_, generated_vals, shrunk_vals)
        generated_value = generated_vals[1]
        shrunk_value = shrunk_vals[1]
      end

      property 'string(len) should shrink to simpler string of same size' {
        generators = { str(length) },
        check = function(x)
          return not is_string(x)  -- always fails!
        end
      }

      for _ = 1, 100 do
        generated_value, shrunk_value = nil, nil
        lqc.check()
        assert.is_equal(length, #shrunk_value)
        assert.is_true(string_sum(shrunk_value) <= string_sum(generated_value))
      end
    end)
  end)
end)

