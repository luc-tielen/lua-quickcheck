local algorithm = require 'lqc.fsm.algorithm'
local state = require 'lqc.fsm.state'
local Vector = require 'lqc.helpers.vector'
local random = require 'lqc.random'
local lqc = require 'lqc.quickcheck'
local lqc_gen = require 'lqc.lqc_gen'
local frequency = lqc_gen.frequency
local oneof = lqc_gen.oneof
local r = require 'lqc.report'
local property = require 'lqc.property'
local int = require 'lqc.generators.int'
local Action = require 'lqc.fsm.action'
local Command = require 'lqc.fsm.command'
local deep_copy = require 'lqc.helpers.deep_copy'
local deep_equals = require 'lqc.helpers.deep_equals'
local map = require 'lqc.helpers.map'
local reduce = require 'lqc.helpers.reduce'


local function do_setup()
  random.seed()
  lqc.init(100, 100)
  lqc.properties = {}
  r.report = function() end
end


-- makes a mock command with a certain state name
local function make_command(cmd_name)
  return Command { cmd_name, function() end, {} }
end


-- Creates a mock state with empty callback functions
local function make_state(state_name)
  return state(state_name) {
    precondition = function () end,
    next_state = function() end,
    postcondition = function() end
  }
end


-- Creates a mock vector with fake data (values are index position)
local function make_vector(x)
  local vec = Vector.new()
  for i = 1, x do
    vec:push_back(i)
  end
  return vec
end


-- computes the sum of the components in a vector
-- the vector should only contain elements that can be summed (i.e. numbers)
local function sum(vec)
  return reduce(vec:to_table(), 0, function(x, acc) return x + acc end)
end


describe('Tests for the FSM algorithm', function()
  before_each(do_setup)

  describe('make_counter helper function', function()
    it('creates a counter which can only increase and return current value', function()
      local ctr = algorithm.make_counter()
      assert.equal(1, ctr:value())
      ctr:increase()
      assert.equal(2, ctr:value())
      ctr:increase()
      assert.equal(3, ctr:value())
      ctr:increase()
      assert.equal(4, ctr:value())
      ctr:increase()
      ctr:increase()
      assert.equal(6, ctr:value())
    end)
  end)

  describe('find_state helper function', function()
    it('finds a state in the list of states if present', function()
      local state1 = make_state 'state1'
      local state2 = make_state 'state2'
      local states = { state1, state2 }
      assert.equal(state1, algorithm.find_state(states, state1.name))
      assert.equal(state2, algorithm.find_state(states, state2.name))
    end)

    it('raises an error if the state is not in the list of states', function()
      local state1 = make_state 'state1'
      local state2 = make_state 'state2'
      local states = { state1, state2 }
      local function try_finding_state(state_name)
        return function() return algorithm.find_state(states, state_name) end
      end
      assert.equal(false, pcall(try_finding_state('non-existing state')))
    end)
  end)

  describe('find_next_action helper function', function()
    local fsm_table = {
      commands = function()  -- model passed in is ignored here for simplicity
        return frequency {
          { 1, make_command 'stop' },
          { 5, make_command '0' },
          { 5, make_command '1' }
        }
      end,
      states = {
        state '0' {
          precondition = function(s) return s == 0 end,
          next_state = function() return 1 end,
          postcondition = function() end
        },
        state '1' {
          precondition = function(s) return s == 1 end,
          next_state = function() return 2 end,
          postcondition = function() end
        },
        state 'stop' {
          precondition = function() return true end,
          next_state = function(s) return s end,
          postcondition = function() end
        }
      },
      initial_state = function() return 0 end,
    }
    local find_next = algorithm.find_next_action

    it('should pick a valid next action', function()
      local spy_check = spy.new(function(state_number)
        local action, new_state = find_next(fsm_table, state_number,
                                            algorithm.make_counter())
        if action.variable.value ~= 1 then return false end
        local cmd_name = action.command.state_name

        if state_number == 0 and cmd_name == '1' then
          -- stop would also be allowed but algorithm has to find 0 too before
          -- tries run out.
          return false
        end
        if state_number == 1 and cmd_name == '0' then
          -- stop is allowed here since no further actions possible after '1'
          return false
        end

        if cmd_name == '0' then
          return new_state == 1
        elseif cmd_name == '1' then
          return new_state == 2
        elseif cmd_name == 'stop' then
          return new_state == state_number
        else
          return false
        end
      end)
      property 'find next action picks a valid next action' {
        generators = { int(2) },
        check = spy_check
      }
      lqc.check()
      assert.spy(spy_check).was.called(lqc.numtests)
    end)

    it('should return a stop command if no next action can be found', function()
      local fsm_table_copy = deep_copy(fsm_table)
      table.remove(fsm_table_copy.states, 3)  -- removes stop state
      fsm_table_copy.commands = function()
        return frequency {
          { 5, make_command '0' },
          { 5, make_command '1' }
        }
      end

      local spy_check = spy.new(function(state_number)
        local action = find_next(fsm_table_copy, state_number,
                                 algorithm.make_counter())
        return action.command.state_name == 'stop'
      end)
      property 'find next action picks a valid next action' {
        generators = { int(5, 10) },  -- precondition will always fail
        check = spy_check
      }
      lqc.check()
      assert.spy(spy_check).was.called(lqc.numtests)
    end)
  end)

  describe('generate_actions helper function', function()
    it('should generate a valid list of actions', function()
      local fsm_table = {
        commands = function()  -- model passed in is ignored here for simplicity
          return frequency {
            { 1, Command.stop },  -- Command.stop = GENERATOR, andere niet?
            { 5, make_command '0' },
            { 5, make_command '1' }
          }
        end,
        states = {
          state '0' {
            precondition = function(s) return s == 0 end,
            next_state = function() return 1 end,
            postcondition = function() end
          },
          state '1' {
            precondition = function(s) return s == 1 end,
            next_state = function() return 2 end,
            postcondition = function() end
          },
          state 'stop' {
            precondition = function() return true end,
            next_state = function(s) return s end,
            postcondition = function() end
          }
        },
        initial_state = function() return 0 end,
      }

      local spy_check = spy.new(function()
        local actions = algorithm.generate_actions(fsm_table)
        local state_names = map(actions:to_table(), function(action)
          return action.command.state_name
        end)
        return deep_equals(state_names, { '0', '1', 'stop' })
          or deep_equals(state_names, { '0', 'stop' })
          or deep_equals(state_names, { 'stop' })
      end)
      property 'generate_actions should generate a valid list of actions' {
        generators = {},
        check = spy_check
      }
      lqc.check()
      assert.spy(spy_check).was.called(lqc.numtests)
    end)
  end)

  describe('slice_last_actions helper function', function()
    it('chops the vector *past* index, whilst retaining the last action ("stop")', function()
      local slice_last_actions = algorithm.slice_last_actions
      local vec_a = Vector.new({ 1, 2, 3, 'stop' })
      assert.same({ 1, 'stop' }, slice_last_actions(vec_a, 1):to_table())
      assert.same({ 1, 2, 'stop' }, slice_last_actions(vec_a, 2):to_table())
      assert.same({ 1, 2, 3, 'stop' }, slice_last_actions(vec_a, 3):to_table())
      assert.same({ 1, 2, 3, 'stop' }, slice_last_actions(vec_a, 4):to_table())

      local vec_b = Vector.new({ 'stop' })
      assert.same({ 'stop' }, slice_last_actions(vec_b, 1):to_table())
    end)
  end)

  describe('select_actions helper function', function()
    it('should return a subset of the actions', function()
      local function contains_no_duplicates(vec)
        for i = 1, vec:size() do
          local val = vec:get(i)
          for j = 1, vec:size() do
            if i ~= j and vec:get(j) == val then
              return false
            end
          end
        end

        return true
      end

      local spy_check = spy.new(function(x)
        local actions = make_vector(x)
        actions:push_back('stop')
        local selected_actions = algorithm.select_actions(actions)

        return (selected_actions:size() < actions:size())
          and (selected_actions:contains('stop') == false)  -- check if last never gets selected
          and (contains_no_duplicates(selected_actions))
        -- NOTE: it's not necessary for selected_actions:size() > 0, this is
        -- allowed in the shrinking algorithm.
      end)

      property 'select_actions returns a random subset of the actions' {
        generators = { int(10) },
        check = spy_check
      }
      lqc.check()
      assert.spy(spy_check).was.called(lqc.numtests)
    end)
  end)

  describe('delete_actions helper function', function()
    it('removes all elements from 1 vector from another vector', function()
      local spy_check = spy.new(function(x, y)
        local vec_a = make_vector(x)
        local vec_b = make_vector(y)
        local vec_c = algorithm.delete_actions(vec_a, vec_b)  -- c = a - b

        for i = 1, vec_b:size() do
          if vec_c:contains(vec_b:get(i)) then return false end
        end
        return true
      end)

      property 'delete_actions removes all actions from 1 vector from another vector' {
        generators = {
          int(1, 10),
          int(1, 5)
        },
        check = spy_check
      }

      lqc.check()
      assert.spy(spy_check).was.called(lqc.numtests)
    end)
  end)

  describe('execute_fsm helper function', function()
    it('should execute the fsm', function()
      local model = 0
      local action_vector = Vector.new()
      local args_vector = Vector.new()
      local spy_cleanup = spy.new(function() end)
      local fsm_table = {
        commands = function()
          return frequency {
            { 1, Command { 'stop', function()
              action_vector:push_back('stop')
            end, {} } },
            { 5, Command { '0', function()
              model = model + 1
              action_vector:push_back(0)
              args_vector:push_back(1)
            end, {} } },
            { 5, Command { '1', function(x)
              model = model + x
              action_vector:push_back(1)
              args_vector:push_back(x)
            end, { int() } } },
            { 3, Command { '2', function()
              action_vector:push_back(2)
            end, {} } }
          }
        end,
        states = {
          state '0' {
            precondition = function() return true end,
            next_state = function(s) return s + 1 end,
            postcondition = function(s) return model == s + 1 end
          },
          state '1' {
            precondition = function() return true end,
            next_state = function(s, _, args) return s + args[1] end,
            postcondition = function(s, _, args) return model == s + args[1] end
          },
          state '2' {
            precondition = function() return true end,
            next_state = function(s) return s end,
            postcondition = function() return false end  -- always fails
          },
          state 'stop' {
            precondition = function() return true end,
            next_state = function(s) return s end,
            postcondition = function() return true end
          }
        },
        initial_state = function() return 0 end,
        cleanup = spy_cleanup,
        numtests = lqc.numtests,
        numshrinks = lqc.numshrinks
      }

      local spy_check = spy.new(function()
        local actions = algorithm.generate_actions(fsm_table)
        local is_ok, last_step = algorithm.execute_fsm(fsm_table, actions)

        -- should fail if 2 was in action list
          -- checks if execute fsm immediately aborts on failing postcondition
        if action_vector:contains(2) then
          if is_ok then return false end
          if last_step ~= action_vector:size() then return false end

          -- manual cleanup needed, otherwise couldn't test this as easily
          model = 0
          action_vector = Vector.new()
          args_vector = Vector.new()
          return true
        end

        -- otherwise should succeed
        if not is_ok then return false end
        if last_step ~= actions:size() - 1 then return false end
        if model ~= sum(args_vector) then return false end

        -- manual cleanup needed, otherwise couldn't test this as easily
        model = 0
        action_vector = Vector.new()
        args_vector = Vector.new()
        return true
      end)
      property 'execute_fsm should execute sequence of actions' {
        generators = {},
        check = spy_check
      }

      lqc.check()
      assert.spy(spy_check).was.called(lqc.numtests)
      assert.spy(spy_cleanup).was.called(lqc.numtests)
    end)
  end)

  describe('is_action_sequence_valid helper function', function()
    local fsm_table = {
      states = {
        state '0' {
          precondition = function(s) return s == 0 end,
          next_state = function() return 1 end,
          postcondition = function() end
        },
        state '1' {
          precondition = function(s) return s == 1 end,
          next_state = function() return 2 end,
          postcondition = function() end
        },
        state '2' {
          precondition = function(s) return s == 2 end,
          next_state = function() return 3 end,
          postcondition = function() end
        }
      },
      initial_state = function() return 0 end,
    }
    local function make_action(state_name)
      return Action.new('unused', Command { state_name, function() end, {} }, {})
    end
    local is_valid = algorithm.is_action_sequence_valid

    it('should return true if sequence is valid', function()
      assert.is_true(is_valid(fsm_table, Vector.new({
        make_action '0'
      })))
      assert.is_true(is_valid(fsm_table, Vector.new({
        make_action '0',
        make_action '1'
      })))
      assert.is_true(is_valid(fsm_table, Vector.new({
        make_action '0',
        make_action '1',
        make_action '2'
      })))
    end)

    it('should return false if sequence is not valid', function()
      assert.is_false(is_valid(fsm_table, Vector.new({
        make_action '1'
      })))
      assert.is_false(is_valid(fsm_table, Vector.new({
        make_action '2'
      })))
      assert.is_false(is_valid(fsm_table, Vector.new({
        make_action '0',
        make_action '2'
      })))
      assert.is_false(is_valid(fsm_table, Vector.new({
        make_action '1',
        make_action '2'
      })))
    end)
  end)

  describe('check function', function()
    it('should execute a correct FSM X amount of times as specified in the fsm_table', function()
      r.report_success = spy.new(r.report_success)
      local counter = 0
      local fsm_table = {
        commands = function()
          return frequency {
            { 1, Command.stop },
            { 10, oneof {
              Command { 'add', function() counter = counter + 1 end, {}},
              Command { 'value', function() return counter end, {} }
            } }
          }
        end,
        initial_state = function() return 0 end,
        states = {
          state 'add' {
            precondition = function() return true end,
            next_state = function(s) return s + 1 end,
            postcondition = function(s) return counter == s + 1 end
          },
          state 'value' {
            precondition = function() return true end,
            next_state = function(s) return s end,
            postcondition = function(s, result) return result == s end,
          },
          state 'stop' {
            precondition = function() return true end,
            next_state = function(s) return s end,
            postcondition = function() return true end
          }
        },
        cleanup = function() counter = 0 end,
        numtests = lqc.numtests
      }

      property 'correct FSM is executed "numtests" of times' {
        check = function()
          algorithm.check('properly working FSM', fsm_table)
          return true
        end,
        generators = {}
      }
      lqc.check()
      local expected_amount =
        lqc.numtests * lqc.numtests  -- loop once from property, once from FSM
        + lqc.numtests  -- property also calls report_success itself
      assert.spy(r.report_success).was.called(expected_amount)
    end)

    it('should be able to shrink down a failing FSM', function()
      local counter = 0
      local history, last_state, last_result = {}, nil, nil
      local spy_when_fail = spy.new(function(the_history, lst_state, lst_result)
        history = the_history
        last_state = lst_state
        last_result = lst_result
      end)
      local fsm_table = {
        commands = function()
          return frequency {
            { 1, Command { 'stop', function() return 'stop_result' end, {} } },
            { 10, oneof {
              Command { 'good_add', function()
                counter = counter + 1
                return 'good_add_result'
              end, {} },
              Command { 'bad_add', function(how_much)
                if counter == 1 then
                  -- we introduce a (obvious) bug here
                  return 'bad_add_result'
                end
                counter = counter + how_much
                return 'bad_add_result'
              end, { int(1, 1000) } }
            } }
          }
        end,
        initial_state = function() return 0 end,
        states = {
          state 'good_add' {
            precondition = function(s) return s ~= 1 end,
            next_state = function(s) return s + 1 end,
            postcondition = function(s) return counter == s + 1 end
          },
          state 'bad_add' {
            precondition = function(s) return s == 1 end,
            next_state = function(s, _, args) return s + args[1] end,
            postcondition = function(s, _, args) return counter == s + args[1] end
          },
          state 'stop' {
            precondition = function() return true end,
            next_state = function(s) return s end,
            postcondition = function() return true end
          }
        },
        numtests = 50,
        numshrinks = 50,
        cleanup = function() counter = 0 end,
        when_fail = spy_when_fail
      }

      local amount = 0
      property 'shrinking of failing FSMs' {
        check = function()
          algorithm.check('test_FSM_name', fsm_table)
          amount = amount + 1

          -- Verify when fail is called at end with simplified sequence:
          assert.spy(spy_when_fail).was.called(amount)

          -- Assert model state corresponds with state right before failure:
          assert.is_equal(1, last_state)

          -- Assert last result is equal to result of last failed action
          assert.is_equal('bad_add_result', last_result)

          -- Verify actions get shrunk down:
          local action_names = map(history, function(action) return action.command.state_name end)
          local args = map(history, function(action) return action.command.args end)

          assert.is_true(deep_equals({ 'good_add', 'bad_add', 'stop' }, action_names)
                      or deep_equals({ 'bad_add', 'bad_add', 'stop' }, action_names))

          -- Verify args get shrunk down:
          if deep_equals({ 'good_add', 'bad_add', 'stop' }, action_names) then
            assert.is_true(deep_equals(args[2], { 1 }))
          elseif deep_equals({ 'bad_add', 'bad_add', 'stop' }, action_names) then
            assert.is_true(deep_equals(args[1], { 0 }))
            assert.is_true(deep_equals(args[2], { 1 }))
          end

          history, last_state, last_result = {}, nil, nil
          return true
        end,
        generators = {},
        numtests = 3,  -- check function itself executes multiple times!
        numshrinks = 50
      }
      lqc.check()
    end)
  end)

  it('should be able to shrink down a FSM, pt2', function()
    local counter = 0
    local should_introduce_glitch = false  -- messes up every command afrer substract is called
    local history, last_state = {}, nil
    local spy_when_fail = spy.new(function(h, s, _)
      history, last_state = h, s
    end)
    local fsm_table = {
      commands = function()
        return frequency {
          { 1, Command.stop },
          { 10, oneof {
            Command { 'add', function()
                if should_introduce_glitch then return end
                counter = counter + 1
              end,
              {} },
            Command { 'subtract', function()
                if should_introduce_glitch then return end
                counter = counter - 1
                should_introduce_glitch = true
              end,
              {} }
          } }
        }
      end,
      initial_state = function() return 0 end,
      states = {
        state 'add' {
          precondition = function() return true end,
          next_state = function(s) return s + 1 end,
          postcondition = function(s) return counter == s + 1 end
        },
        state 'subtract' {
          precondition = function() return true end,
          next_state = function(s) return s - 1 end,
          postcondition = function(s) return counter == s - 1 end
        },
        state 'stop' {
          precondition = function() return true end,
          next_state = function(s) return s end,
          postcondition = function() return true end
        }
      },
      cleanup = function() counter = 0 end,
      when_fail = spy_when_fail,
      numtests = 50,
      numshrinks = 50
    }
    local amount = 0
    property 'shrinking of failing FSMs, pt2' {
      numtests = 3,
      generators = {},
      check = function()
        algorithm.check('FSM can be shrunk down, pt2', fsm_table)
        amount = amount + 1

        -- Verify when fail is called at end with simplified sequence:
        assert.spy(spy_when_fail).was.called(amount)
        -- Assert model state corresponds with state right before failure:
        assert.is_equal(counter, last_state)
        -- Verify actions get shrunk down:
        local action_names = map(history, function(action) return action.command.state_name end)
        assert.is_true(deep_equals({ 'add', 'stop' }, action_names)
                    or deep_equals({ 'subtract', 'stop' }, action_names))

        history, last_state = {}, nil
        return true
      end
    }
    lqc.check()
  end)

  it('should be able to shrink down a FSM, pt3', function()
    local should_introduce_glitch = true
    local counter, counter_copy = 0, 0
    local history, last_state = {}, nil
    local spy_when_fail = spy.new(function(h, s, _)
      history, last_state = h, s
    end)
    local fsm_table = {
      commands = function()
        return frequency {
          { 1, Command.stop },
          { 10, Command { 'add', function(x)
              if should_introduce_glitch then
                -- this glitch is only triggered once, afterwards works fine
                counter = counter + x / 2
                counter_copy = counter
                should_introduce_glitch = false
                return
              end
              counter = counter + x
            end,
            { int(1, 100) } }
          }
        }
      end,
      initial_state = function() return 0 end,
      states = {
        state 'add' {
          precondition = function() return true end,
          next_state = function(s, _, args) return s + args[1] end,
          postcondition = function(s, _, args) return counter == s + args[1] end
        },
        state 'stop' {
          precondition = function() return true end,
          next_state = function(s) return s end,
          postcondition = function() return true end
        }
      },
      cleanup = function() counter = 0 end,
      when_fail = spy_when_fail,
      numtests = 50,
      numshrinks = 50
    }
    local amount = 0
    property 'shrinking of failing FSMs, pt3' {
      numtests = 3,
      generators = {},
      check = function()
        algorithm.check('FSM can be shrunk down, pt3', fsm_table)
        amount = amount + 1

        -- Verify when fail is called at end with simplified sequence:
        assert.spy(spy_when_fail).was.called(amount)
        -- Verify actions get shrunk down:
        local action_names = map(history, function(action) return action.command.state_name end)
        assert.is_true(deep_equals({ 'add', 'stop' }, action_names))
        -- Verify args get shrunk down
        local args = map(history, function(action) return action.command.args end)
        assert.is_true(deep_equals(args[1], { last_state }))
        assert.is_true(last_state == 2 * counter_copy)

        history, last_state = {}, nil
        should_introduce_glitch = true  -- reactivate glitch
        counter_copy = 0
        return true
      end
    }
    lqc.check()
  end)

  it('should be able to shrink down a FSM, pt4', function()
    local should_introduce_glitch = false
    local amount = 0
    local counter = 0
    local history = {}
    local spy_when_fail = spy.new(function(h)
      history = h
    end)
    local fsm_table = {
      commands = function()
        return frequency {
          { 1, Command.stop },
          { 10, oneof {
            Command { '1', function()
              counter = 1
            end, {} },
            Command { '2', function()
              counter = 2
            end, {} },
            Command { '3', function()
              counter = 4
            end, {} }
          }
        } }
      end,
      initial_state = function() return 0 end,
      states = {
        state '1' {
          precondition = function(s)
            return s == 0 or should_introduce_glitch
          end,
          next_state = function() return 1 end,
          postcondition = function(s) return counter == s + 1 end
        },
        state '2' {
          precondition = function(s) return s == 1 end,
          next_state = function() return 2 end,
          postcondition = function(s) return counter == s + 1 end
        },
        state '3' {
          precondition = function(s)
            local introduce_glitch = should_introduce_glitch
            should_introduce_glitch = true
            return s == 2 or introduce_glitch
          end,
          next_state = function() return 3 end,
          postcondition = function(s) return counter == s + 1 or should_introduce_glitch end
        },
        state 'stop' {
          precondition = function() return true end,
          next_state = function(s) return s end,
          postcondition = function() return true end
        }
      },
      cleanup = function() counter = 0 end,
      when_fail = spy_when_fail,
      numtests = 50,
      numshrinks = 50
    }

    property 'shrinking down failed FSMs, pt4' {
      generators = {},
      check = function()
        algorithm.check('FSM can be shrunk down, pt3', fsm_table)
        amount = amount + 1

        -- Verify when fail is called at end with simplified sequence:
        assert.spy(spy_when_fail).was.called(amount)
        -- Verify actions get shrunk down:
        local action_names = map(history, function(action) return action.command.state_name end)
        assert.is_true(action_names[#action_names - 1] == '3'
                    or action_names[#action_names - 1] == '1')
        assert.is_true(action_names[1] == '1'
                    or action_names[1] == '3')

        history = {}
        return true
      end,
      numtests = 3
    }
    lqc.check()
  end)
end)

