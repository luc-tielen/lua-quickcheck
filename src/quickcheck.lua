local report = require 'src.report'
local results = require 'src.property_result'

local unpack = unpack or table.unpack  -- for compatibility reasons
local shuffle = pairs
local lib = {}
lib.properties = {}  -- list of all properties
lib.iteration_amount = 100  -- TODO make configurable
lib.shrink_amount = 100     -- TODO make configurable

function lib.shrink(property, generated_values, tries)
  if not tries then tries = 0 end
  local shrunk_values = property:shrink(unpack(generated_values))
  local result = property(unpack(shrunk_values))
  
  if tries == lib.shrink_amount then
    -- Maximum amount of shrink attempts exceeded. 
    return generated_values
  end

  -- TODO think about correct behavior for when skipped..
  if result == results.FAILURE or result == results.SKIPPED then
    -- further try to shrink down
    return lib.shrink(property, shrunk_values, tries + 1)
  end

  -- return generated values since they were last values for which property failed!
  return generated_values
end


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
    for _ = 1, prop.iteration_amount do
      local generated_values = prop:pick()
      local result = prop(unpack(generated_values))

      if result == results.SUCCESS then
        report.report_success()
      elseif result == results.SKIPPED then
        report.report_skipped()
      else
        if #generated_values == 0 then
          -- Empty list of generators -> no further shrinking possible!
          report.report_failed(prop, generated_values, generated_values)
          break -- TODO remove break? or make configurable?
        end

        local shrunk_values = lib.shrink(prop, generated_values)
        report.report_failed(prop, generated_values, shrunk_values)
        break  -- TODO remove break? or make configurable?
      end
    end
  end
end


return lib

