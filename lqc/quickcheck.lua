local report = require 'lqc.report'
local map = require 'lqc.helpers.map'


local shuffle = pairs
local lib = {
  properties = {},  -- list of all properties
  numtests = nil,   -- Default amount of times a property should be tested
  numshrinks = nil  -- Default amount of times a failing property should be shrunk down
}


-- Is the quickcheck configuration initialized?
-- Returns true if it is initialized; otherwise false.
local function is_initialized()
  return lib.numtests ~= nil and lib.numshrinks ~= nil
end


-- Handles the result of a property.
local function handle_result(result)
  if not result then return end   -- successful
  if type(result.property) == 'table' then  -- property failed
    report.report_failed_property(result.property, 
                                  result.generated_values, 
                                  result.shrunk_values)
    return
  end

  -- FSM failed
  report.report_failed_fsm(result.description, 
                           result.generated_values, 
                           result.shrunk_values)
end


-- Configures the amount of iterations and shrinks the check algorithm should
-- perform.
function lib.init(numtests, numshrinks)
  lib.numtests = numtests
  lib.numshrinks = numshrinks
end


-- Iterates over all properties in a random order and checks if the property
-- holds true for each generated set of inputs.
function lib.check()
  if not is_initialized() then
    error 'quickcheck.init() has to be called before quickcheck.check()!'
  end

  for _, prop in shuffle(lib.properties) do
    local result = prop:check() 
    handle_result(result)
  end
end


-- Multithreaded version of check(), uses a thread pool underneath
function lib.check_mt(numthreads)
  local ThreadPool = require 'lqc.threading.thread_pool'

  if not is_initialized() then
    error 'quickcheck.init() has to be called before quickcheck.check_mt()!'
  end

  local pool = ThreadPool.new(numthreads)
  for _, prop in shuffle(lib.properties) do
    pool:schedule(function() return prop:check() end)
  end
  local results = pool:join()
  map(results, handle_result)
end


return lib

