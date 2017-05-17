local Var = require 'lqc.fsm.var'


describe('Variable helper object', function()
  it('is necessary to provide a value to the Var helper', function()
    local function make_var(value)
      local function func()
        return Var.new(value)
      end
      return func
    end
    assert.equal(true, pcall(make_var(1)))
    assert.equal(true, pcall(make_var('2')))
    assert.equal(false, pcall(make_var()))
  end)

  it('should have a string representation', function()
    assert.equal('{ var, 1234 }', Var.new(1234):to_string())
    assert.equal('{ var, 25 }', Var.new("25"):to_string())
  end)
end)

