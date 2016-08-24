local random = require 'lqc.random'
local lqc = require 'lqc.quickcheck'
local results = require 'lqc.property_result'
local property = require 'lqc.property'
local r = require 'lqc.report'
local Gen = require 'lqc.generator'

local function do_setup()
  random.seed()
  lqc.init(100, 100)
  lqc.properties = {}
  r.report = function() end
end

local function dummy_gen()
  return Gen.new(function() return 1 end, function(prev) return prev end)
end


describe('property helper function', function()
  before_each(do_setup)

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
  before_each(do_setup)

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

  describe('numtests', function()
    it('executes a property X amount of times if specified', function()
      local spy_check1 = spy.new(function() return true end)
      property 'property with default iteration amount' {
        generators = {},
        check = spy_check1
      }
      lqc.check()
      assert.spy(spy_check1).was.called(lqc.numtests)
      lqc.properties = {}

      local spy_check2 = spy.new(function() return true end)
      local new_iteration_amount = lqc.numtests + 10
      property 'property with non-default iteration_amount' {
        generators = {},
        check = spy_check2,
        numtests = new_iteration_amount
      }
      lqc.check()
      assert.spy(spy_check2).was.called(new_iteration_amount)
    end)
  end)

  describe('numshrinks', function()
    it('shrinks a property X amount of times if specified', function()
      property 'property with default shrinks amount' {
        generators = { dummy_gen() },
        check = function() return false end
      }
      lqc.properties[1].shrink = spy.new(lqc.properties[1].shrink)
      lqc.check()
      assert.spy(lqc.properties[1].shrink).was.called(lqc.numshrinks)
      lqc.properties = {}

      local new_shrink_amount = lqc.numshrinks + 10
      property 'property with non-default shrink_amount' {
        generators = { dummy_gen() },
        check = function() return false end,
        numshrinks = new_shrink_amount
      }
      lqc.properties[1].shrink = spy.new(lqc.properties[1].shrink)
      lqc.check()
      assert.spy(lqc.properties[1].shrink).was.called(new_shrink_amount)
    end)
  end)
end)

