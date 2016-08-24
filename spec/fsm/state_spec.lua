local state = require 'lqc.fsm.state'

-- Helper function to make a state
local function make_state(state_name, precond, next_state, postcond)
  local state_helper = state(state_name)
  local function do_make_state()
    return state_helper {
      precondition = precond,
      next_state = next_state,
      postcondition = postcond
    }
  end
  return do_make_state
end


describe('state helper object', function()
  it('is necessary to provide a name, next_state, pre- and postcondition', function()
    local name = 'state_name'
    local function next_state() end
    local function precondition() end
    local function postcondition() end
    assert.equal(false, pcall(make_state(nil, nil, nil, nil)))
    assert.equal(false, pcall(make_state(name, nil, nil, nil)))
    assert.equal(false, pcall(make_state(name, precondition, nil, nil)))
    assert.equal(false, pcall(make_state(name, precondition, next_state, nil)))
    assert.equal(true, pcall(make_state(name, precondition, next_state, postcondition)))
    assert.equal(false, pcall(function() state(name)(nil) end))
  end)

  it('returns a table containing precondition, next_state and postcondition', function()
    local state_name = 'name of the state'
    local function precondition() end
    local function next_state() end
    local function postcondition() end

    local a_state = state 'name of the state' {
      precondition = precondition,
      next_state = next_state,
      postcondition = postcondition
    }

    assert.equal(state_name, a_state.name)
    assert.equal(precondition, a_state.precondition)
    assert.equal(next_state, a_state.next_state)
    assert.equal(postcondition, a_state.postcondition)
  end)
end)

