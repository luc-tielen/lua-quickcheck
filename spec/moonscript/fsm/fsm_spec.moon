random = require 'lqc.random'
r = require 'lqc.report'
command = require 'lqc.fsm.command'
fsm = require 'lqc.fsm'
state = require 'lqc.fsm.state'
lqc = require 'lqc.quickcheck'
lqc_gen = require 'lqc.lqc_gen'
frequency = lqc_gen.frequency
oneof = lqc_gen.oneof
elements = lqc_gen.elements


do_setup = ->
  random.seed!
  lqc.init 100, 100
  lqc.properties = {}
  r.report = ->


-- 'example code to test':
new_counter = ->
  Counter =
    x: 0
    add: (y) => @x += y
    value: => @x
    reset: => @x = 0

  Counter

ctr = new_counter!
counter_add = (x) -> ctr\add(x)
counter_reset = -> ctr\reset!


-- FSM specification:

describe 'statemachine specification', ->
  before_each(do_setup)

  it 'should be possible to define a FSM', ->
    r.report_success = spy.new(r.report_success)

    fsm 'counter'
      commands: (state) ->
        -- NOTE: conditional commands can be added with an if, ... before returning list
        frequency {
          { 1, command.stop },
          { 10, oneof {
            command { 'increment', counter_add, { elements { 1, 2, 3 } } },
            command { 'reset', counter_reset, {} }
          } }
        }
      initial_state: -> 0
      states: {
        state 'increment'
          precondition: (state, args) ->  -- args are in a table!
            true  -- always allowed
          next_state: (state, value, args) ->  -- called after applying command from commands function
            state + args[1]
          postcondition: (state, result, args) ->  -- result is actual value returned by command
            ctr\value! == state + args[1]
        state 'reset'
          precondition: (state, args) -> true
          next_state: (state, value, args) -> 0,
          postcondition: (state, result, args) -> ctr\value! == 0
      }
      cleanup: (state) -> ctr = new_counter!
      when_fail: (history, state, result) ->
        print action\to_string! for action in *history
    
    assert.equal(1, #lqc.properties)
    lqc.check()
    assert.spy(r.report_success).was.called(lqc.numtests)

