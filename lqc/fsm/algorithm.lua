local Vector = require 'lqc.helpers.vector'
local Var = require 'lqc.fsm.var'
local Command = require 'lqc.fsm.command'
local Action = require 'lqc.fsm.action'
local random = require 'lqc.random'
local deep_copy = require 'lqc.helpers.deep_copy'
local report = require 'lqc.report'
local unpack = unpack or table.unpack  -- for compatibility reasons


local lib = {}


-- Creates a small helper object that keeps track of a counter
function lib.make_counter()
  local Counter = {
    val = 1,
    increase = function(self) self.val = self.val + 1 end,
    value = function(self) return self.val end
  }
  return setmetatable(Counter, { __index = Counter })
end


-- Checks if x lies between min and max
-- Returns true if min <= x and x <= max.
local function is_between(x, min, max)
  return min <= x and x <= max
end


-- How many items should be shrunk?
-- returns a random number between 1 and max_amount (inclusive)
local function shrink_how_many(max_amount)
  if max_amount <= 1 then return 1 end
  return random.between(1, max_amount)
end


-- Should an action be marked for deletion?
local function should_select_action()
  return random.between(1, 4) == 1  -- 25% chance
end


-- Finds a specific state in the list of states based on name of the state.
-- Raises an error if no state is present with the specified name; otherwise
-- returns the state with that name.
function lib.find_state(states, state_name)
  for i = 1, #states do
    local state = states[i]
    if state.name == state_name then return state end
  end
  error('State "' .. state_name .. '" not found in list of FSM states!')
end


-- Finds the next command based on the FSM model and the current state.
-- Returns 3 values: chosen_command, cmd_generator, updated_current_state
function lib.find_next_action(fsm, current_state, var_counter)
  local numtests, commands, states = fsm.numtests, fsm.commands, fsm.states
  local cmd_gen = commands(current_state)

  for _ = 1, 100 do  -- TODO make configurable?
    local cmd = cmd_gen:pick(numtests)
    local selected_state = lib.find_state(states, cmd.state_name)
 
    if selected_state.precondition(current_state, cmd.args) then  -- valid command
      local variable = Var.new(var_counter:value())
      var_counter:increase()
      current_state = selected_state.next_state(current_state, variable, cmd.args)
      return Action.new(variable, cmd, cmd_gen), current_state
    end
  end

  -- Could not find a next action -> stop generating further actions
  return Action.new(Var.new(var_counter:value()), Command.stop, nil), current_state 
end


-- Generates a list of steps for a FSM specification
function lib.generate_actions(fsm_table)
  local generated_actions = Vector.new()
  local counter = lib.make_counter()
  local state = fsm_table.initial_state()

  repeat
    local action, next_state = lib.find_next_action(fsm_table, state, counter)
    state = next_state
    generated_actions:push_back(action)
  until action.command.state_name == 'stop'

  return generated_actions
end


-- Slices of the last actions past index
-- Returns the action vector (modified in place)
function lib.slice_last_actions(action_vector, index)
  local action_vector_copy = deep_copy(action_vector)
  local last_pos = action_vector_copy:size() - 1  -- -1 since we want to keep stop action!
  for i = last_pos, index + 1, -1 do
    action_vector_copy:remove_index(i)
  end
  return action_vector_copy
end


-- Selects at most 'how_many' amount of actions from the vector of actions 
-- to be marked for deletion.
-- returns a vector of actions which should be deleted.
function lib.select_actions(action_vector)
  local selected_actions, idx_vector = Vector.new(), Vector.new()
  if action_vector:size() <= 2 then return selected_actions, idx_vector end
  local amount = 0
  local size = action_vector:size() - 2  -- don't remove stop action, keep atleast 1 other action
  local how_many = shrink_how_many(size)
  
  for i = 1, size do  
    if amount >= how_many then break end
    if should_select_action() then  -- TODO make this a variable function and use a while loop?
      idx_vector:push_back(i)
      amount = amount + 1
    end
  end

  for i = 1, amount do
    selected_actions:push_back(action_vector:get(idx_vector:get(i)))
  end

  return selected_actions, idx_vector
end


-- Removes all elements of 'which_actions' from 'action_vector'
-- returns an updated vector
function lib.delete_actions(action_vector, which_actions)
  local action_vector_copy = deep_copy(action_vector)
  for i = 1, which_actions:size() do
    action_vector_copy:remove(which_actions:get(i))
  end
  return action_vector_copy
end


-- Does the actual execution of the FSM by executing the list of actions
-- If one of the postconditions fail after an action is applied, then the
-- actions will be shrunk down to a simpler scenario.
-- At the end, the state is cleaned up by the cleanup-callback.
-- Returns 4 values:
-- 1) true if the FSM property succeeded for these actions; false otherwise.
-- 2) index of last successful step (1-based)
-- 3) state of the model right before the failing action
-- 4) result of the last failing action
function lib.execute_fsm(fsm_table, generated_actions)
  local state = fsm_table.initial_state()
  local last_state, last_result = state, nil

  for i = 1, generated_actions:size() do
    local command = generated_actions:get(i).command
    local selected_state = lib.find_state(fsm_table.states, command.state_name)
    local result = command.func(unpack(command.args))  -- side effects happen here
    local updated_state = selected_state.next_state(state, result, command.args)
    
    last_state, last_result = state, result

    -- and verify the model matches the actual system
    -- NOTE: the state passed in is the state that the system had BEFORE
    -- executing this specific action!
    if not selected_state.postcondition(state, result, command.args) then
      fsm_table.cleanup(state)
      return false, i, last_state, last_result
    end

    state = updated_state  -- update model
  end

  fsm_table.cleanup(state)
  return true, generated_actions:size() - 1, last_state, last_result
end


-- Is the list of actions valid to execute on this FSM?
-- Replays sequence symbolically to verify if it is indeed valid.
-- returns true if list of actions valid; otherwise false.
function lib.is_action_sequence_valid(fsm_table, action_vector)
  local states = fsm_table.states
  local state = fsm_table.initial_state()
  
  for i = 1, action_vector:size() do
    local action = action_vector:get(i)
    local selected_state = lib.find_state(states, action.command.state_name)
    
    if not selected_state.precondition(state, action.command.args) then
      return false
    end

    state = selected_state.next_state(state, action.variable, action.command.args)
  end
  return true
end


-- Tries to shrink the list of actions to a simpler form by removing steps of
-- the sequence and checking if it is still valid.
-- The function is recursive and will loop until tries_left is 0.
-- Returns 2 values:
-- 1) action_list if shrinking was not possible after X amount of tries;
--    otherwise it will return a shrunk list of actions.
-- 2) list of deleted actions (empty if shrinking failed after X tries)
local function do_shrink_actions(fsm_table, action_list)
  local which_actions = lib.select_actions(action_list)
  local shrunk_actions = lib.delete_actions(action_list, which_actions)
  
  if not lib.is_action_sequence_valid(fsm_table, shrunk_actions) then
    return action_list, Vector.new()
  end

  return shrunk_actions, which_actions
end


-- Does the shrinking of the FSM actions
-- choose 1 - N steps and delete them from list of actions
-- repeat X amount of times (recursively)
-- returns the shrunk down list
local function shrink_actions(fsm_table, generated_actions, removed_actions, tries)
  if tries == 1 then return generated_actions, removed_actions end
  
  local shrunk_actions, deleted_actions = do_shrink_actions(fsm_table, generated_actions)
  local total_removed_actions = removed_actions:append(deleted_actions)

  -- TODO add execute fsm here and shrink deleted actions?

  return shrink_actions(fsm_table, shrunk_actions, total_removed_actions, tries - 1)
end


-- Tries to shrink the list of failing actions by selecting a subset and
-- checking if the combination is now valid and if the FSM still fails or not
-- This is a recursive function which returns 3 things:
-- 1. the shrunk list of actions (or the original list if no better solution was found)
-- 2. the end state of the fsm after these actions
-- 3. result of the last action
local function shrink_deleted_actions(fsm_table, generated_actions, deleted_actions, tries)
  if tries == 1 then return generated_actions end
  
  local which_actions = lib.select_actions(deleted_actions)
  local shrunk_actions = lib.delete_actions(generated_actions, which_actions)

  -- Retry if invalid sequence
  local is_valid = lib.is_action_sequence_valid(fsm_table, shrunk_actions)
  if not is_valid then return shrink_deleted_actions(fsm_table, generated_actions, deleted_actions, tries - 1) end

  -- Check FSM again
  -- if FSM succeeds now, (one or more of) the failing actions have been deleted
  --    -> simply retry TODO there is an optimisation possible here..
  -- else FSM still failed -> chosen actions did not matter, ignore them and
  --      further try shrinking
  local is_successful = lib.execute_fsm(fsm_table, shrunk_actions)
  if is_successful then deleted_actions = lib.delete_actions(deleted_actions, which_actions) end
  return shrink_deleted_actions(fsm_table, shrunk_actions, deleted_actions, tries - 1)
end


function lib.shrink_fsm_actions(fsm_table, generated_actions, step, tries)
  if tries == 1 then return generated_actions end

  local sliced_actions = lib.slice_last_actions(generated_actions, step)  -- cut off actions after failure..
  local shrunk_actions, deleted_actions = shrink_actions(fsm_table, sliced_actions,
                                                         Vector.new(), fsm_table.numshrinks)
  if deleted_actions:size() == 0 then
    -- shrinking did not help, try again
    return lib.shrink_fsm_actions(fsm_table, sliced_actions, step, tries - 1)
  end

  -- shrinking did help, retry FSM:
  local is_successful1, new_step1 = lib.execute_fsm(fsm_table, shrunk_actions)
  if not is_successful1 then
    -- FSM still fails, deleted actions can be ignored, try further shrinking
    return lib.shrink_fsm_actions(fsm_table, shrunk_actions, new_step1, tries - 1)
  end

  -- now FSM works -> faulty action is in the just deleted actions   
  local shrunk_down_actions = shrink_deleted_actions(fsm_table, sliced_actions,
                                                     deleted_actions, fsm_table.numshrinks)
  -- retry fsm:
  -- if a solution could not be found by shrinking down the deleted actions
  --    -> sliced actions is smallest solution found
  -- else if FSM still fails after shrinking deleted_actions 
  --    -> try further shrinking
  local is_successful2, new_step2 = lib.execute_fsm(fsm_table, shrunk_down_actions)
  local minimal_actions = is_successful2 and sliced_actions or shrunk_down_actions
  return lib.shrink_fsm_actions(fsm_table, minimal_actions, new_step2, tries - 1)
end


local function select_actions_for_arg_shrinking(action_list)
  local _, idx_vector = lib.select_actions(action_list)
  if idx_vector:size() == 0 and is_between(action_list:size(), 2, 10) then
    -- try shrinking 1 action anyway
    local idx = random.between(1, action_list:size() - 1)  -- don't shrink stop action!
    idx_vector:push_back(idx)
  end
  return idx_vector
end


-- Does the actual shrinking of the command arguments of a sequence of actions.
-- Returns an updated sequence of the action list (original is modified!) with
-- shrunk arguments.
local function shrink_args(fsm_table, action_list)
  local idx_vector = select_actions_for_arg_shrinking(action_list)
  
  for i = idx_vector:size(), 1, -1 do  -- shrunk from end to beginning (most likely to succeed)
    local idx = idx_vector:get(i)
    local action = action_list:get(idx)
  
    for _ = 1, fsm_table.numshrinks do
      local command_copy = action.command  -- shallow copy (reference only)
      action.command = action.cmd_gen:shrink(action.command)
      -- revert if shrink is not valid
      local is_valid = lib.is_action_sequence_valid(fsm_table, action_list)
      if not is_valid then action.command = command_copy; break end
    end
  end

  return action_list
end


local function shrink_fsm_args(fsm_table, generated_actions, tries)
  if tries == 1 then return generated_actions end

  local shrunk_actions = shrink_args(fsm_table, 
                                     deep_copy(generated_actions), 
                                     fsm_table.numshrinks)
  
  -- retry FSM
  local is_successful = lib.execute_fsm(fsm_table, shrunk_actions)
  if not is_successful then
    -- FSM still fails, shrinking of args was successful, try further shrinking
    return shrink_fsm_args(fsm_table, shrunk_actions, tries - 1)
  end

  -- FSM works now, shrinking of args unsuccessful -> retry
  return shrink_fsm_args(fsm_table, generated_actions, tries - 1)
end


-- Replays the FSM
-- Returns the last state and result while executing the FSM.
local function replay_fsm(fsm_table, action_vector)
  local _, _, last_state, last_result = lib.execute_fsm(fsm_table, action_vector)
  return last_state, last_result
end


-- Shrinks the list of generated actions for a given FSM.
-- This is a recursive function which keeps trying for X amount of times.
-- Returns the shrunk list of actions or the original action list if shrinking
-- did not help.
local function shrink_fsm(fsm_table, generated_actions, step)
  local fsm_shrink_amount = fsm_table.numshrinks 
  local shrunk_actions = lib.shrink_fsm_actions(fsm_table, generated_actions, step, fsm_shrink_amount)
  local shrunk_actions_and_args = shrink_fsm_args(fsm_table, shrunk_actions, fsm_shrink_amount)
  local lst_state, lst_result = replay_fsm(fsm_table, shrunk_actions_and_args)
  return shrunk_actions_and_args, lst_state, lst_result
end


-- The main checking function for FSM specifications
-- Checks a number of times (according to FSM spec) if property is true.
-- If the specification failed, then the result will be shrunk down to a
-- simpler case.
function lib.check(description, fsm_table)
  for _ = 1, fsm_table.numtests do
    local generated_actions = lib.generate_actions(fsm_table)
  
    local is_successful, last_step = lib.execute_fsm(fsm_table, generated_actions)
    if not is_successful then
      local shrunk_actions, last_state, last_result = shrink_fsm(fsm_table,
                                                                 generated_actions, 
                                                                 last_step)
      report.report_failed_fsm(description)
      fsm_table.when_fail(shrunk_actions:to_table(), last_state, last_result)
      return
    end
    
    report.report_success()
  end
end


return lib

