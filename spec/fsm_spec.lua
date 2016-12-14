local random = require 'lqc.random'
local r = require 'lqc.report'
local command = require 'lqc.fsm.command'
local fsm = require 'lqc.fsm'
local state = require 'lqc.fsm.state'
local algorithm = require 'lqc.fsm.algorithm'
local lqc = require 'lqc.quickcheck'
local lqc_gen = require 'lqc.lqc_gen'
local frequency = lqc_gen.frequency
local oneof = lqc_gen.oneof
local elements = lqc_gen.elements


local function do_setup()
  random.seed()
  lqc.init(100, 100)
  lqc.properties = {}
  r.report = function() end
end


-- 'example code to test':
local function new_counter()
  local Counter = { x = 0 }
  function Counter:add(y) self.x = self.x + y end
  function Counter:value() return self.x end
  function Counter:reset() self.x = 0 end
  return Counter
end

local ctr = new_counter()
local function counter_add(x) ctr:add(x) end
local function counter_reset() ctr:reset() end


-- FSM specification:

-- NOTE: this is only in a function for some code reuse during tests
-- seeing as the FSM spec can get quite lengthy..
local function describe_counter_fsm(iteration_amount)
  fsm 'counter' {
    commands = function()  -- parameters: s (symbolic state during generation)
      -- NOTE: conditional commands can be added with an if, ... (based on state)
      -- before returning list
      return frequency {
        { 1, command.stop },
        { 10, oneof {
          command { 'increment', counter_add, { elements { 1, 2, 3 } } },
          command { 'reset', counter_reset, {} }
        } }
      }
    end,
    initial_state = function() return 0 end,
    states = {
      state 'increment' {
        precondition = function()  -- parameters: s (state), args (in a table)
          -- NOTE: this function is called during test case generation to generate
          -- random sequence of events and during shrinking to check if the shrunk
          -- sequence is still valid
          return true  -- always allowed
        end,
        next_state = function(s, _, args)   -- parameters: s (state), v (value = (symbolic or real) result, args (table)
          -- NOTE: this function is called both during test case generation
          -- (to update symbolic state of the model) and during FSM execution
          -- (to update real state of the model)
          return s + args[1]
        end,
        postcondition = function(s, _, args)  -- parameters: s (state), r (result), args (table)
          -- NOTE: s = state *before* command was executed!
          -- r is actual value returned by command
          return ctr:value() == s + args[1]
        end
      },
      state 'reset' {
        precondition = function(_) return true end,
        next_state = function(_) return 0 end,
        postcondition = function() return ctr:value() == 0 end
      }
    },
    cleanup = function(_)  -- takes a parameter s (end state after running X actions)
      ctr = new_counter()
    end,
    when_fail = function()  -- parameters: history, state, result
      -- ...
    end,
    numtests = iteration_amount
  }
end

local function describe_failing_fsm(shrink_amount)
  fsm 'failing' {
    commands = function()
      return frequency {
        { 1, command.stop },
        { 10, oneof {
          command { 'failing_state', function() end, {} },
        } }
      }
    end,
    initial_state = function() return 0 end,
    states = {
      state 'failing_state' {
        precondition = function() return true end,
        next_state = function() return true end,
        postcondition = function() return false end  -- always fails
      },
    },
    cleanup = function(_) end,
    when_fail = function() end,
    numshrinks = shrink_amount
  }
end


describe('statemachine specification', function()
  before_each(do_setup)

  it('should be possible to define a FSM', function()
    r.report_success = spy.new(r.report_success)
    describe_counter_fsm()
    assert.equal(1, #lqc.properties)
    lqc.check()
    assert.spy(r.report_success).was.called(lqc.iteration_amount)
  end)

  it('should be impossible to create incomplete or wrong FSM specifications', function()
    -- NOTE: sadly cannot check function return type / arguments.
    assert.is_false(pcall(function() fsm(nil) {} end))
    assert.is_false(pcall(function() fsm(1) {} end))
    assert.is_false(pcall(function() fsm 'missing commands' {
      initial_state = function() return 0 end,
      states = {
        state '1' {
          precondition = function() end,
          next_state = function() end,
          postcondition = function() end
        }
      },
    } end))
    assert.is_false(pcall(function() fsm 'missing initial_state' {
      commands = function() end,
      states = {
        state '1' {
          precondition = function() end,
          next_state = function() end,
          postcondition = function() end
        }
      },
    } end))
    assert.is_false(pcall(function() fsm 'missing states' {
      commands = function() end,
      initial_state = function() return 0 end,
    } end))
    assert.is_false(pcall(function() fsm 'missing precondition in a state' {
      commands = function() end,
      initial_state = function() return 0 end,
      states = {
        state '1' {
          next_state = function() end,
          postcondition = function() end
        }
      }
    } end))
    assert.is_false(pcall(function() fsm 'invalid precondition in a state' {
      commands = function() end,
      initial_state = function() return 0 end,
      states = {
        state '1' {
          precondition = 'invalid (not callable)',
          next_state = function() end,
          postcondition = function() end
        }
      }
    } end))
    assert.is_false(pcall(function() fsm 'missing next_state in a state' {
      commands = function() end,
      initial_state = function() return 0 end,
      states = {
        state '1' {
          precondition = function() end,
          postcondition = function() end
        }
      }
    } end))
    assert.is_false(pcall(function() fsm 'invalid next_state in a state' {
      commands = function() end,
      initial_state = function() return 0 end,
      states = {
        state '1' {
          precondition = function() end,
          next_state = 'invalid (not callable)',
          postcondition = function() end
        }
      }
    } end))
    assert.is_false(pcall(function() fsm 'missing postcondition in a state' {
      commands = function() end,
      initial_state = function() return 0 end,
      states = {
        state '1' {
          precondition = function() end,
          next_state = function() end,
        }
      }
    } end))
    assert.is_false(pcall(function() fsm 'invalid postcondition in a state' {
      commands = function() end,
      initial_state = function() return 0 end,
      states = {
        state '1' {
          precondition = function() end,
          next_state = function() end,
          postcondition = 'invalid (not callable)'
        }
      }
    } end))
  end)

  it('should be possible to specify how many times a FSM is executed', function()
    r.report_success = spy.new(r.report_success)
    describe_counter_fsm(1)
    lqc.check()
    assert.spy(r.report_success).was.called(1)
    lqc.properties = {}
    describe_counter_fsm(100)
    lqc.check()
    assert.spy(r.report_success).was.called(1 + 100)
  end)

  it('should be possible to modify number of shrinks', function()
    algorithm.shrink_fsm_actions = spy.new(algorithm.shrink_fsm_actions)
    describe_failing_fsm(1)
    lqc.check()
    assert.spy(algorithm.shrink_fsm_actions).was.called(1)
    lqc.properties = {}
    describe_failing_fsm(10)
    lqc.check()
    assert.spy(algorithm.shrink_fsm_actions).was.called(1 + 10)
  end)
end)

