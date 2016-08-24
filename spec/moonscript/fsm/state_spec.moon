state = require 'lqc.fsm.state'


make_state = (name, precondition, next_state, postcondition) ->
  ->
    state name,
      precondition: precondition
      next_state: next_state,
      postcondition: postcondition


describe 'state helper object (moonscript integration', ->
  it 'is necessary to provide a name, next_state, pre- and postcondition', ->
    name = 'state_name'
    next_state = ->
    precondition = ->
    postcondition = ->

    assert.equal(false, pcall(make_state(nil, nil, nil, nil)))
    assert.equal(false, pcall(make_state(name, nil, nil, nil)))
    assert.equal(false, pcall(make_state(name, precondition, nil, nil)))
    assert.equal(false, pcall(make_state(name, precondition, next_state, nil)))
    assert.equal(true, pcall(make_state(name, precondition, next_state, postcondition)))
    assert.equal(false, pcall(-> state name nil))


  it 'returns a table containing precondition, next_state and postcondition', ->
    state_name = 'name of the state'
    precondition = ->
    next_state = ->
    postcondition = ->
    
    a_state = state 'name of the state'
      precondition: precondition
      next_state: next_state
      postcondition: postcondition
 
    assert.equal(state_name, a_state.name)
    assert.equal(precondition, a_state.precondition)
    assert.equal(next_state, a_state.next_state)
    assert.equal(postcondition, a_state.postcondition)

