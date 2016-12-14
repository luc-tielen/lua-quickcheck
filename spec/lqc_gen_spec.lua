local random = require 'lqc.random'
local r = require 'lqc.report'
local property = require 'lqc.property'
local lqc_gen = require 'lqc.lqc_gen'
local lqc = require 'lqc.quickcheck'


local function do_setup()
  random.seed()
  lqc.init(100, 100)
  lqc.properties = {}
  r.report = function() end
end


describe('choose', function()
  before_each(do_setup)

  it('chooses a number between min and max', function()
    local min1, max1 = 569, 1387
    local spy_check_pos = spy.new(function(x)
      return x >= min1 and x <= max1
    end)
    property 'chooses a number between min and max (positive integers)' {
      generators = { lqc_gen.choose(min1, max1) },
      check = spy_check_pos
    }

    local min2, max2 = -1337, -50
    local spy_check_neg = spy.new(function(x)
      return x >= min2 and x <= max2
    end)
    property 'chooses a number between min and max (negative integers)' {
      generators = { lqc_gen.choose(min2, max2) },
      check = spy_check_neg
    }

    lqc.check()
    assert.spy(spy_check_pos).was.called(lqc.numtests)
    assert.spy(spy_check_neg).was.called(lqc.numtests)
  end)

  it('shrinks the generated value towards the value closest to 0', function()
    local min1, max1 = 5, 10
    local shrunk_value1 = nil
    r.report_failed_property = function(_, _, shrunk_vals)
      shrunk_value1 = shrunk_vals[1]
    end
    property 'shrinks the generated value towards min value (positive integers)' {
    generators = { lqc_gen.choose(min1, max1) },
      check = function(x)
        return x < min1  -- always false
      end
    }

    lqc.check()
    assert.same(min1, shrunk_value1)

    lqc.properties = {}
    local min2, max2 = -999, -333
    local shrunk_value2 = nil
    r.report_failed_property = function(_, _, shrunk_vals)
      shrunk_value2 = shrunk_vals[1]
    end
    property 'shrinks the generated value towards min value (negative integers)' {
      generators = { lqc_gen.choose(min2, max2) },
      check = function(x)
        return x < min2  -- always false
      end
    }

    lqc.check()
    assert.same(max2, shrunk_value2)
  end)
end)

describe('oneof', function()
  before_each(do_setup)

  it('chooses a generator from a list of generators', function()
    local min1, max1, min2, max2 = 1, 10, 11, 20
    local shrunk_value = nil
    r.report_failed_property = function(_, _, shrunk_vals)
      shrunk_value = shrunk_vals[1]
    end
    local spy_check = spy.new(function(x)
      return x <= max1  -- only succeeds for 1st generator
    end)
    property 'oneof chooses a generator from a list of generators' {
      generators = {
        lqc_gen.oneof {
          lqc_gen.choose(min1, max1),
          lqc_gen.choose(min2, max2)
        }
      },
      check = spy_check
    }

    lqc.check()
    assert.is_same(min2, shrunk_value)
    assert.spy(spy_check).was.not_called(lqc.numtests)
  end)

  it('chooses the same generator each time if only 1 is supplied.', function()
    local min, max = 1, 10
    local spy_check = spy.new(function(x)
      return x <= max
    end)
    property 'oneof chooses a generator from a list of generators' {
      generators = {
        lqc_gen.oneof {
          lqc_gen.choose(min, max),
        }
      },
      check = spy_check
    }

    lqc.check()
    assert.spy(spy_check).was.called(lqc.numtests)
  end)

  it('shrinks one of the generated values from the supplied list of generators', function()
    local which_gen, shrunk_value = nil, nil
    local spy_shrink1 = spy.new(function() return 1 end)
    local spy_shrink2 = spy.new(function() return 2 end)

    local function gen_1()
      local gen = {}
      function gen.pick(_) which_gen = 1; return 1 end
      gen.shrink = spy_shrink1
      return gen
    end
    local function gen_2()
      local gen = {}
      function gen.pick(_) which_gen = 2; return 2 end
      gen.shrink = spy_shrink2
      return gen
    end
    r.report_failed_property = function(_, _, shrunk_vals)
      shrunk_value = shrunk_vals[1]
    end

    property 'oneof shrinks generated value with correct generator' {
      generators = {
        lqc_gen.oneof {
          gen_1(),
          gen_2()
        }
      },
      check = function(_)
        return false
      end
    }

    for _ = 1, 10 do
      lqc.check()
      assert.not_equal(nil, which_gen)
      assert.not_equal(nil, shrunk_value)
      assert.equal(which_gen, shrunk_value)
    end

    assert.spy(spy_shrink1).was.called()
    assert.spy(spy_shrink2).was.called()
  end)
end)

describe('frequency', function()
  before_each(do_setup)

  it('chooses a generator from a list of weighted generators', function()
    local x, y, weight1, weight2 = 0, 0, 2, 8
    local gen1, gen2 = lqc_gen.choose(1, 10), lqc_gen.choose(11, 20)
    local gen1_pick, gen2_pick = gen1.pick_func, gen2.pick_func
    gen1.pick_func = function()
      x = x + 1
      return gen1_pick()
    end
    gen2.pick_func = function()
      y = y + 1
      return gen2_pick()
    end
    property 'frequency chooses a generator from a list of weighted generators' {
      generators = {
        lqc_gen.frequency {
          { weight1, gen1 },
          { weight2, gen2 }
        }
      },
      check = function(_)
        return true
      end
    }

    lqc.check()
    assert.not_equal(0, x)
    assert.not_equal(0, y)
    local function expected_calls(weight)
      return lqc.numtests / (weight1 + weight2) * weight
    end

    local function almost_equal(a, b, margin)
      return a <= b + margin and a >= b - margin
    end
    assert.is_true(almost_equal(x, expected_calls(weight1), 10))
    assert.is_true(almost_equal(y, expected_calls(weight2), 10))
  end)

  it('chooses the same generator each time if only 1 is supplied.', function()
    local gen1 = lqc_gen.choose(1, 100)
    local spy_pick = spy.new(gen1.pick_func)
    gen1.pick_func = spy_pick
    property 'frequency chooses a generator from a list of weighted generators' {
      generators = {
        lqc_gen.frequency {
          { 10 , gen1 }
        }
      },
      check = function(_)
        return true
      end
    }

    lqc.check()
    assert.spy(spy_pick).was.called(lqc.numtests)
  end)

  it('shrinks one of the generated values from the supplied list of weighted generators', function()
    local which_gen, shrunk_value = nil, nil
    local spy_shrink1 = spy.new(function() return 1 end)
    local spy_shrink2 = spy.new(function() return 2 end)

    local function gen_1()
      local gen = {}
      function gen.pick(_) which_gen = 1; return 1 end
      gen.shrink = spy_shrink1
      return gen
    end
    local function gen_2()
      local gen = {}
      function gen.pick(_) which_gen = 2; return 2 end
      gen.shrink = spy_shrink2
      return gen
    end
    r.report_failed_property = function(_, _, shrunk_vals)
      shrunk_value = shrunk_vals[1]
    end

    property 'frequency shrinks generated value with correct generator' {
      generators = {
        lqc_gen.frequency {
          { 1, gen_1() },
          { 1, gen_2() }
        }
      },
      check = function(_)
        return false
      end
    }

    for _ = 1, 30 do
      lqc.check()
      assert.not_equal(nil, which_gen)
      assert.not_equal(nil, shrunk_value)
      assert.equal(which_gen, shrunk_value)
      which_gen, shrunk_value = nil, nil
    end

    assert.spy(spy_shrink1).was.called()
    assert.spy(spy_shrink2).was.called()
  end)
end)

describe('elements', function()
  before_each(do_setup)

  it('generates an element out of a list', function()
    local input = { 1, 'a', false, {}, -1.5 }
    local spy_check = spy.new(function(_)
      return true -- always succeeds
    end)
    property 'elements generates an element out of a list' {
      generators = { lqc_gen.elements(input) },
      check = spy_check
    }

    lqc.check()
    for i = 1, #input do
      assert.spy(spy_check).was.called_with(input[i])
    end
  end)

  it('shrinks towards the beginning of the list', function()
    local input = { false, {}, 1, 'a',  -1.5, function() end }
    local shrunk_value
    r.report_failed_property = function(_, _, shrunk_vals)
      shrunk_value = shrunk_vals[1]
    end
    property 'elements shrinks to beginning of the list, pt1' {
      generators = { lqc_gen.elements(input) },
      check = function(_)
        return false  -- always fails
      end
    }

    lqc.check()
    assert.equal(input[1], shrunk_value)

    lqc.properties = {}
    property 'elements shrinks to beginning of the list, pt2' {
      generators = { lqc_gen.elements(input) },
      check = function(x)
        return type(x) == 'boolean'
      end
    }
    lqc.check()
    assert.equal('table', type(shrunk_value))
  end)

end)

describe('combinations of the above', function()
  before_each(do_setup)

  it('should be possible to combine frequency and oneof helpers', function()
    local spy_shrink1 = spy.new(function() return 1 end)
    local spy_shrink2 = spy.new(function() return 2 end)
    local spy_shrink3 = spy.new(function() return 3 end)

    local which_gen, shrunk_value
    r.report_failed_property = function(_, _, shrunk_vals)
      shrunk_value = shrunk_vals[1]
    end
    local function gen_1()
      local gen = {}
      function gen.pick(_) which_gen = 1; return 1 end
      gen.shrink = spy_shrink1
      return gen
    end
    local function gen_2()
      local gen = {}
      function gen.pick(_) which_gen = 2; return 2 end
      gen.shrink = spy_shrink2
      return gen
    end
    local function gen_3()
      local gen = {}
      function gen.pick(_) which_gen = 3; return 3 end
      gen.shrink= spy_shrink3
      return gen
    end

    property 'frequency shrinks generated value with correct generator' {
      generators = {
        lqc_gen.frequency {
          { 1, lqc_gen.oneof { gen_1(), gen_2() } },
          { 1, gen_3() }
        }
      },
      check = function(_) return false end
    }

    for _ = 1, 30 do
      lqc.check()
      assert.not_equal(nil, which_gen)
      assert.not_equal(nil, shrunk_value)
      assert.equal(which_gen, shrunk_value)
      which_gen, shrunk_value = nil, nil
    end

    assert.spy(spy_shrink1).was.called()
    assert.spy(spy_shrink2).was.called()
    assert.spy(spy_shrink3).was.called()
  end)
end)

