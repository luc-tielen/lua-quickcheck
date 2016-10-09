
--- Module for describing an action in a 'declarative' way
-- @classmod lqc.fsm.action
-- @alias Action

local Action = {}
local Action_mt = { __index = Action }


--- Creates a new action.
-- @param var (Symbolic) variable to store the result of the action in
-- @param cmd Command that was called during this action
-- @param command_generator Generator that generated the command, used for shrinking the command
-- @return new action object
function Action.new(var, cmd, command_generator)  -- TODO rename to args_generators
  if var == nil then
    error 'Need to provide variable to action object!'
  end
  if cmd == nil then
    error 'Need to provide command to action object!'
  end

  local action = { 
    variable = var, 
    command = cmd,
    cmd_gen = command_generator
  }
  return setmetatable(action, Action_mt)
end


--- Returns a string representation of the action
-- @return string representation of the action
function Action:to_string()
  return '{ set, ' .. self.variable:to_string() .. 
              ', ' .. self.command:to_string() .. ' }'
end

return Action

