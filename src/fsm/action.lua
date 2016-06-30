
local Action = {}
local Action_mt = { __index = Action }

function Action.new(var, cmd)
  if var == nil then
    error 'Need to provide variable to action object!'
  end
  if cmd == nil then
    error 'Need to provide command to action object!'
  end

  local action = { variable = var, command = cmd }
  return setmetatable(action, Action_mt)
end

function Action:to_string()
  return '{ set, ' .. self.variable:to_string() .. 
              ', ' .. self.command:to_string() .. ' }'
end

return Action

