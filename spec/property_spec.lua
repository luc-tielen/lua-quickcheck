local lqc = require 'src.quickcheck'
local p = require 'src.property'
local property = p.property
local results = p.results
local function clear_properties()
  lqc.properties = {}  
end

local gen = {}
function gen:new()
  return 'test generator placeholder' --TODO
end

describe('property helper function', function()
  before_each(clear_properties)

  it('should add function to array of other properties', function()
    assert.is.equal(0, #lqc.properties)
    
    property 'easiest prop' {
      generators = {},
      check = function()
        return true
      end
    }
    assert.is.equal(1, #lqc.properties)
    
    property 'test_property1' {
      generators = { gen:new(), gen:new() },
      check = function()
        return x + y == y + x
      end
    }
    assert.is.equal(2, #lqc.properties)
  end)
end)

describe('property', function()
  before_each(clear_properties)

  it('should be callable', function()
    property 'a property' {
      generators = {},
      check = function()
        return true
      end
    }
    local prop = lqc.properties[1]
    assert.equal(results.SUCCESS, prop())
  end)

  describe('check', function() 
    it('should return SUCCESS when property is truthy', function()
      property 'a bad property' {
        generators = {},
        check = function()
          return true
        end
      }
      assert.equal(results.SUCCESS, lqc.properties[1]())
      
    end)
    it('should return FAILURE when property is falsy', function()
      property 'a bad property' {
        generators = {},
        check = function()
          return false
        end
      }
      assert.equal(results.FAILURE, lqc.properties[1]())
    end)
  end)
  
  describe('implies', function()
    it('should return SKIPPED if implies constraint is not met', function()
      property 'a skipped property' {
        generators = {},
        check = function()
          return true
        end,
        implies = function()
          return false
        end
      } 
      assert.equal(results.SKIPPED, lqc.properties[1]())
    end)

    it('should execute the normal check function if the constraint is met', function()
      property 'a good property' {
        generators = {},
        check = function()
          return true
        end,
        implies = function()
          return true
        end
      } 
      assert.equal(results.SUCCESS, lqc.properties[1]())

      property 'a bad property' {
        generators = {},
        check = function()
          return false
        end,
        implies = function()
          return true
        end
      } 
      assert.equal(results.FAILURE, lqc.properties[2]())
    end)
  end)

  describe('when_fail', function()
    it('should execute the when_fail if property failed', function()
      local x = 0
      property 'a bad property' {
        generators = {},
        check = function()
          return false
        end,
        when_fail = function()
          x = x + 1
        end
      } 
      assert.equal(results.FAILURE, lqc.properties[1]())
      assert.equal(1, x)
    end)
    it('should not execute the when_fail otherwise', function()
      local x = 0
      property 'a bad property' {
        generators = {},
        check = function()
          return true
        end,
        when_fail = function()
          x = x + 1
        end
      } 
      assert.equal(results.SUCCESS, lqc.properties[1]())
      assert.equal(0, x)
    end)
  end)
end)

