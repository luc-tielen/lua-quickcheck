local lqc = require 'src.quickcheck'
local results = require 'src.property_result'
local p = require 'src.property'
local property = p.property

local function clear_properties()
  lqc.properties = {}  
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
      generators = {},
      check = function()
        return false
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

  it('should raise an error if no generators are specified', function()
    local function make_bad_prop()
      property 'test property' {
        check = function()
          return true
        end
      }
    end
    local result = pcall(make_bad_prop)
    assert.equal(false, result)
  end)

  it('should raise an error if no check function is specified', function()
    local function make_bad_prop()
      property 'test property' {
        generators = {}
      }
    end
    local result = pcall(make_bad_prop)
    assert.equal(false, result)
  end)

  describe('check', function() 
    it('should return SUCCESS when property is truthy', function()
      property 'a good property' {
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
      local on_fail = spy.new(function() end)
      property 'a bad property' {
        generators = {},
        check = function()
          return false
        end,
        when_fail = on_fail
      } 
      assert.equal(results.FAILURE, lqc.properties[1]())
      assert.spy(on_fail).was.called(1)
    end)

    it('should not execute the when_fail otherwise', function()
      local on_fail = spy.new(function() end)
      property 'a bad property' {
        generators = {},
        check = function()
          return true
        end,
        when_fail = on_fail
      } 
      assert.equal(results.SUCCESS, lqc.properties[1]())
      assert.spy(on_fail).was.not_called()
    end)
  end)
end)

