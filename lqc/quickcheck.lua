
--- Module which contains the core of the quickcheck engine.
-- @module lqc.quickcheck
-- @alias lib

local report = require 'lqc.report'
local map = require 'lqc.helpers.map'


local shuffle = pairs
local lib = {
  properties = {},  -- list of all properties
  numtests = nil,   -- Default amount of times a property should be tested
  numshrinks = nil,  -- Default amount of times a failing property should be shrunk down
  failed = false
}


--- Checks if the quickcheck configuration is initialized
-- @return true if it is initialized; otherwise false.
local function is_initialized()
  return lib.numtests ~= nil and lib.numshrinks ~= nil
end


--- Handles the result of a property.
-- @param result table containing information of the property (or nil on success)
-- @see lqc.property_result
local function handle_result(result)
  if not result then return end   -- successful
  lib.failed = true
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


--- Configures the amount of iterations and shrinks the check algorithm should perform.
-- @param numtests Default number of tests per property
-- @param numshrinks Default number of shrinks per property
function lib.init(numtests, numshrinks)
  lib.numtests = numtests
  lib.numshrinks = numshrinks
end


--- Iterates over all properties in a random order and checks if the property
--  holds true for each generated set of inputs. Raises an error if quickcheck
--  engine is not initialized yet.
function lib.check()
  if not is_initialized() then
    error 'quickcheck.init() has to be called before quickcheck.check()!'
  end

  for _, prop in shuffle(lib.properties) do
    local result = prop:check()
    handle_result(result)
  end
end


--- Multithreaded version of check(), uses a thread pool in the underlying
--  implementation. Splits up the properties over different threads.
-- @param numthreads Number of the threads to divide the properties over.
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

