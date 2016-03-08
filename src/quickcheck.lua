local report = require 'src.report'
local results = require 'src.property_result'

local lib = {}
lib.properties = {}  -- list of all properties
lib.iteration_amount = 100  -- TODO make configurable
local shuffle = pairs

-- Workflow:
-- 1. loop over all properties
-- 2. for each property, do the following X amount of times:
--  2.1 check result of property:
--    - SUCCESS = OK, print '.'
--    - SKIPPED = OK, print 'x'
--    - FAILURE = NOT OK, see 3.
-- 3. if FAILURE:
--  3.1 print property info, values for which it fails
--  3.2 do shrink to find minimal error case
--  3.3 when shrink stays the same or max amount exceeded -> print minimal example
--  3.4 (later) save seed to a file somewhere, for re-running stuff..
function lib.check()
  for _, prop in shuffle(lib.properties) do
    for _ = 1, lib.iteration_amount do
      local result = prop()
      if result == results.SUCCESS then
        report.report_success()
      elseif result == results.SKIPPED then
        report.report_skipped()
      else
        report.report_failed()
        -- TODO shrink
        break
      end
    end
  end
end


return lib

