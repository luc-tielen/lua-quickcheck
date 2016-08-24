local deep_equals = require 'lqc.helpers.deep_equals'
local random = require 'lqc.random'
local r = require 'lqc.report'
local lqc = require 'lqc.quickcheck'
local property = require 'lqc.property'
local int = require 'lqc.generators.int'
local str = require 'lqc.generators.string'
local bool = require 'lqc.generators.bool'
local tbl = require 'lqc.generators.table'
local Vector = require 'lqc.helpers.vector'


local function do_setup()
  random.seed()
  lqc.init(100, 100)
  lqc.properties = {}
  r.report = function() end
end


describe('deep_equals', function()
  before_each(do_setup)

  describe('ints', function()
    it('returns true if ints are the same', function()
      local spy_check = spy.new(function(x) return deep_equals(x, x) end)
      property 'deep_equals for 2 same integers returns true' {
        check = spy_check,
        generators = { int() }
      }
      lqc.check()
      assert.spy(spy_check).was.called(lqc.numtests)
    end)

    it('returns false if ints are not the same', function()
      r.report_failed_property = spy.new(r.report_failed_property)
      property 'deep_equals returns false for 2 different integers' {
        check = function(x, y) return not deep_equals(x, y) end,
        implies = function(x, y) return x ~= y end,
        generators = { int(), int() }
      }
      lqc.check()
      assert.spy(r.report_failed_property).was.not_called()
    end)
  end)

  describe('strings', function()
    it('returns true if strings are the same', function()
      local spy_check = spy.new(function(x) return deep_equals(x, x) end)
      property 'deep_equals returns true for strings that are the same' {
        generators = { str(3) },
        check = spy_check
      }
      lqc.check()
      assert.spy(spy_check).was.called(lqc.numtests)
    end)

    it('returns false for 2 different strings', function()
      r.report_failed_property = spy.new(r.report_failed_property)
      property 'deep_equals returns false for 2 different strings' {
        generators = { str(3), str(3) },
        check = function(x, y) return not deep_equals(x, y) end,
        implies = function(x, y) return x ~= y end
      }
      lqc.check()
      assert.spy(r.report_failed_property).was.not_called()
    end)
  end)

  describe('booleans', function()
    it('returns true if 2 booleans are the same', function()
      local spy_check = spy.new(function(x) return deep_equals(x, x) end)
      property 'deep_equals returns true for 2 booleans of equal value' {
        generators = { bool() },
        check = spy_check
      }
      lqc.check()
      assert.spy(spy_check).was.called(lqc.numtests)
    end)

    it('returns false for 2 different boolean values', function()
      r.report_failed_property = spy.new(r.report_failed_property)
      property 'deep_equals returns false for 2 booleans containing different values' {
        generators = { bool(), bool() },
        check = function(x, y) return not deep_equals(x, y) end,
        implies = function(x, y) return x ~= y end
      }
      lqc.check()
      assert.spy(r.report_failed_property).was.not_called()
    end)
  end)

  describe('tables (and nested structures in general)', function()
    it('returns true if 2 tables contain the same values (also recursively)', function()
      local spy_check = spy.new(function(x) return deep_equals(x, x) end)
      property 'deep_equals returns true for tables that contain same values' {
        generators = { tbl(3) },
        check = spy_check
      }
      lqc.check()
      assert.spy(spy_check).was.called(lqc.numtests)
    end)

    it('returns false if 2 tables contain different values (also recursively)', function()
      local x1, y1 = { 1, 2, 3 }, { 1, 2, 4 }
      local x2, y2 = { '1', '2', '3' }, { '4', '5', '6' }
      local x3, y3 = { 1, '2', '3' }, { '1', '2', '3' }
      local x4, y4 = { { true, 'test' }, 1 }, { { true, '123' }, 1 }
      assert.is_false(deep_equals(x1, y1))
      assert.is_false(deep_equals(x2, y2))
      assert.is_false(deep_equals(x3, y3))
      assert.is_false(deep_equals(x4, y4))
    end)
  end)

  describe('vectors (or general object with metatables etc)', function()
    it('returns true if 2 vectors are the same', function()
      local x1, y1 = Vector.new(), Vector.new()
      local x2, y2 = Vector.new({ 1, 2, 3 }), Vector.new({ 1, 2, 3 })
      local x3, y3 = Vector.new({ 1, 'a', true }), Vector.new({ 1, 'a', true })
      local x4, y4 = Vector.new({ 1, { 2, true } }), Vector.new({ 1, { 2, true } })
      assert.is_true(deep_equals(x1, y1))
      assert.is_true(deep_equals(x2, y2))
      assert.is_true(deep_equals(x3, y3))
      assert.is_true(deep_equals(x4, y4))
    end)

    it('returns false if 2 vectors are different', function()
      local x1, y1 = Vector.new(), Vector.new({ 1 })
      local x2, y2 = Vector.new({ 1 }), Vector.new()
      local x3, y3 = Vector.new({ 1, 'a', true }), Vector.new({ 1, 'a', false })
      local x4, y4 = Vector.new({ 1, { 2, true } }), Vector.new({ 1, { 2, false } })
      local x5, y5 = Vector.new({ 1, { 2, true } }), Vector.new({ 1, { 2, true, 3 } })
      assert.is_false(deep_equals(x1, y1))
      assert.is_false(deep_equals(x2, y2))
      assert.is_false(deep_equals(x3, y3))
      assert.is_false(deep_equals(x4, y4))
      assert.is_false(deep_equals(x5, y5))
    end)
  end)
end)

