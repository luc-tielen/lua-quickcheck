
-- Checks if object is callable (a function or a functable)
-- returns true if obj is callable; otherwise false.
local function is_callable(obj)
  local type_obj = type(obj)
  return type_obj == 'function' or type_obj == 'table' 
end


-- Checks if the state contains all the necessary info for a valid state specification
-- Raises an error if state contains wrong or missing information.
local function check_valid_state(state, state_name)
  if type(state_name) ~= 'string' then
    error 'Missing state name!'
  end
  if type(state) ~= 'table' then
    error 'State should be specified as a table!'
  end
  if not is_callable(state.precondition) then
    error('Need to provide a precondition function to state ' .. state_name .. '!')
  end
  if not is_callable(state.next_state) then
    error('Need to provide a next_state function to state ' .. state_name .. '!')
  end
  if not is_callable(state.postcondition) then
    error('Need to provide a postcondition function to state ' .. state_name .. '!')
  end
end


-- Helper function for specifying a state in the FSM
local function make_state(state_name, state_information)
  local function make_state_helper(state_info)
    check_valid_state(state_info, state_name)
    return {
      name = state_name,
      precondition = state_info.precondition,
      next_state = state_info.next_state,
      postcondition = state_info.postcondition
    }
  end

  if state_information ~= nil then
    -- Called with normal syntax, directly return result
    return make_state_helper(state_information)
  end

  -- called with Lua DSL syntax, return closue which returns result
  return make_state_helper 
end


return make_state

