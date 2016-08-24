
local Action = require 'lqc.fsm.action'


local function mock_obj(value)
  local obj = {}
  local obj_mt = { 
    __index = function() 
      return function() 
        return value 
      end 
    end 
  }
  return setmetatable(obj, obj_mt)
end


describe('Action helper object', function()
  it('is necessary to pass a variable and command to the Action helper', function()
    local function make_action(var, cmd)
      local function func()
        return Action.new(var, cmd)
      end
      return func
    end
    local var = 'dummy_var'
    local cmd = 'dummy_cmd'
    assert.equals(false, pcall(make_action()))
    assert.equals(false, pcall(make_action(var)))
    assert.equals(false, pcall(make_action(nil, cmd)))
    assert.equals(true, pcall(make_action(var, cmd)))
  end)

  it('should be possible to represent the action as a string', function()
    local expected1 = '{ set, var1, cmd1 }'
    local expected2 = '{ set, var2, cmd2 }'
    assert.equal(expected1, Action.new(mock_obj('var1'), mock_obj('cmd1')):to_string())
    assert.equal(expected2, Action.new(mock_obj('var2'), mock_obj('cmd2')):to_string())
  end)
end)

