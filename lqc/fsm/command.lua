local Gen = require 'lqc.generator'
local random = require 'lqc.random'
local deep_copy = require 'lqc.helpers.deep_copy'


-- Returns a string representation of the command.
local function stringify(cmd)
  local result = {
    '{ call, ',
    cmd.state_name,
  }
  
  local size_result = #result
  for i = 1, #cmd.args do
    -- TODO allow printing of table etc..
    result[i + size_result] = ', ' .. cmd.args[i]
  end
  
  result[#result + 1] = ' }'
  return table.concat(result)
end


-- Creates a function that picks a random value for each of the generators
-- specified in the argument list. 
-- Returns a table with keys { state_name, func, args }
local function pick(state_name, command_func, args_generators)
  local function do_pick(num_tests)
    local args = {}
    for i = 1, #args_generators do
      args[i] = args_generators[i]:pick(num_tests)
    end
    return { 
      state_name = state_name,
      func = command_func,
      args = args,
      to_string = stringify
    }
  end
  return do_pick
end


-- Does the actual shrinking of the args
-- Randomly picks 1 of the arguments and shrinks it, rest stays the same
local function shrink_args(prev_args, args_generators)
  local idx = random.between(1, #prev_args)
  local shrunk_arg = args_generators[idx]:shrink(prev_args[idx])
  local args_copy = deep_copy(prev_args)
  args_copy[idx] = shrunk_arg
  return args_copy
end


-- Shrinks the command to a simpler form.
-- Only args are shrunk, state_name and func are unmodified.
local function shrink(state_name, command_func, args_generators)
  local function do_shrink(previous)
    if #previous.args == 0 then return previous end
    return {
      state_name = state_name, 
      func = command_func, 
      args = shrink_args(previous.args, args_generators),
      to_string = stringify
    }
  end
  return do_shrink
end


-- Creates a new command generator with a state_name, command function
-- and a list of generators (args will be passed into the command_func in the FSM)
local function new(state_name, command_func, args_generators)
  local generator = Gen.new(pick(state_name, command_func, args_generators),
                            shrink(state_name, command_func, args_generators))
  generator.state_name = state_name
  return generator
end


local command = {}
local command_mt = {
  __call = function(_, command_tbl)
    return new(command_tbl[1], command_tbl[2], command_tbl[3])
  end
}

command.stop = new('stop', function() end, {})

return setmetatable(command, command_mt)

