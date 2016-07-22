local random = require 'src.random'
local char = require 'src.generators.char'
local r = require 'src.report'
local property = require 'src.property'
local lqc = require 'src.quickcheck'

local lowest_ascii_value = 32
local highest_ascii_value = 126
local lowest_ascii_char = string.char(lowest_ascii_value)

local function is_readable_char(value)
  local char_value = string.byte(value)
  return type(value) == 'string' 
     and string.len(value) == 1
     and char_value >= lowest_ascii_value
     and char_value <= highest_ascii_value
end

local function do_setup()
  random.seed()
  lqc.properties = {}
  r.report = function() end
end


describe('char generator module', function()

  describe('pick function', function()
    before_each(do_setup)
    it('should pick a char', function()
      local spy_check = spy.new(function(x) return is_readable_char(x) end)
      property 'char() should pick a char' {
        generators = { char() },
        check = spy_check
      }
      lqc.check()
      assert.spy(spy_check).was.called(lqc.iteration_amount)
    end)
  end)

  describe('shrink function', function()
    before_each(do_setup)
    it('should converge to " "', function()
      local shrunk_values
      r.report_failed_property = function(_, _, shrunk_vals)
        shrunk_values = shrunk_vals[1]
      end
      property 'char() should converge to 32 (lowest allowed ASCII value)' {
        generators = { char() },
        check = function(x)
          return not is_readable_char(x)  -- always fails!
        end
      }

      for _ = 1, 100 do
        shrunk_values = nil
        lqc.check()
        assert.equal(lowest_ascii_char, shrunk_values)
      end
    end)
  end)
end)

