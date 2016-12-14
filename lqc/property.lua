
--- Module for creating properties. Provides a small domain specific language
--  for ease of use.
--  @module lqc.property
--  @alias property

local lqc = require 'lqc.quickcheck'
local report = require 'lqc.report'
local results = require 'lqc.property_result'
local unpack = unpack or table.unpack  -- for compatibility reasons


--- Helper function, checks if x is an integer.
-- @param x a value to be checked
-- @return true if x is an integer; false otherwise.
local function is_integer(x)
  return type(x) == 'number' and x % 1 == 0
end


--- Adds a small wrapper around the check function indicating success or failure
-- @param prop_table Property to be wrapped.
local function add_check_wrapper(prop_table)
  local check_func = prop_table.check
  prop_table.check = function(...)
    if check_func(...) then
      return results.SUCCESS
    else
      return results.FAILURE
    end
  end
end


--- Adds an 'implies' wrapper to the check function
-- @param prop_table Property to be wrapped.
local function add_implies(prop_table)
  local check_func = prop_table.check
  prop_table.check = function(...)
    if prop_table.implies(...) == false then
      return results.SKIPPED
    end

    return check_func(...)
  end
end


--- Adds a 'when_fail' wrapper to the check function
-- @param prop_table Property to be wrapped.
local function add_when_fail(prop_table)
  local check_func = prop_table.check
  prop_table.check = function(...)
    local result = check_func(...)

    if result == results.FAILURE then
      prop_table.when_fail(...)
    end

    return result
  end
end


--- Shrinks a property that failed with a certain set of inputs.
--  This function is called recursively if a shrink fails.
--  This function returns a simplified list or inputs.
-- @param property the property that failed
-- @param generated_values array of values to be shrunk down
-- @param tries Amount of shrinking tries already done
-- @return array of shrunk down values
local function do_shrink(property, generated_values, tries)
  if not tries then tries = 1 end
  local shrunk_values = property.shrink(unpack(generated_values))
  local result = property(unpack(shrunk_values))

  if tries == property.numshrinks then
    -- Maximum amount of shrink attempts exceeded.
    return generated_values
  end

  if result == results.FAILURE then
    -- further try to shrink down
    return do_shrink(property, shrunk_values, tries + 1)
  elseif result == results.SKIPPED then
    -- shrunk to invalid situation, retry
    return do_shrink(property, generated_values, tries + 1)
  end

  -- return generated values since they were last values for which property failed!
  return generated_values
end


--- Function that checks if the property is valid for a set amount of inputs.
-- 1. check result of property X amount of times:
--    - SUCCESS = OK, print '.'
--    - SKIPPED = OK, print 'x'
--    - FAILURE = NOT OK, see 2.
-- 2. if FAILURE:
--  2.1 print property info, values for which it fails
--  2.2 do shrink to find minimal error case
--  2.3 when shrink stays the same or max amount exceeded -> print minimal example
--  @param property Property to be checked X amount of times.
--  @return nil on success; otherwise returns a table containing error info.
local function do_check(property)
  for _ = 1, property.numtests do
    local generated_values = property.pick()
    local result = property(unpack(generated_values))

    if result == results.SUCCESS then
      report.report_success()
    elseif result == results.SKIPPED then
      report.report_skipped()
    else
      report.report_failed()
      if #generated_values == 0 then
        -- Empty list of generators -> no further shrinking possible!
        return {
          property = property,
          generated_values = generated_values,
          shrunk_values = generated_values
        }
      end

      local shrunk_values = do_shrink(property, generated_values)
      return {
        property = property,
        generated_values = generated_values,
        shrunk_values = shrunk_values
      }
    end
  end

  return nil
end


--- Creates a new property.
-- NOTE: property is limited to 1 implies, for_all, when_fail
-- more complex scenarios should be handled with state machine.
-- @param descr String containing description of the property
-- @param property_func Function to be checked X amount of times
-- @param generators List of generators used to generate values supplied to 'property_func'
-- @param numtests Number of times the property should be checked
-- @param numshrinks Number of times a failing property should be shrunk down
-- @return property object
local function new(descr, property_func, generators, numtests, numshrinks)
  local prop = {
    description = descr,
    numtests = numtests,
    numshrinks = numshrinks
  }

  -- Generates a new set of inputs for this property.
  -- Returns the newly generated set of inputs as a table.
  function prop.pick()
    local generated_values = {}
    for i = 1, #generators do
      generated_values[i] = generators[i]:pick(numtests)
    end
    return generated_values
  end

  -- Shrink 1 value randomly out of the given list of values.
  function prop.shrink(...)
    local values = { ... }
    local which = math.random(#values)
    local shrunk_value = generators[which]:shrink(values[which])
    values[which] = shrunk_value
    return values
  end

  -- Function that checks if the property is valid for a set amount of inputs.
  function prop:check()
    return do_check(self)
  end

  return setmetatable(prop, {
    __call = function(_, ...)
      return property_func(...)
    end
  })
end


--- Inserts the property into the list of existing properties.
-- @param descr String containing text description of the property
-- @param prop_info_table Table containing information of the property
-- @return nil; raises an error if prop_info_table is not in a valid format
local function property(descr, prop_info_table)
  local function prop_func(prop_table)
    local generators = prop_table.generators
    if not generators or type(generators) ~= 'table' then
      error('Need to supply generators in property!')
    end

    local check_type = type(prop_table.check)
    if check_type ~= 'function' and check_type ~= 'table' then
      error('Need to provide a check function to property!')
    end

    add_check_wrapper(prop_table)

    local implies_type = type(prop_table.implies)
    if implies_type == 'function' or implies_type == 'table' then
      add_implies(prop_table)
    end

    local when_fail_type = type(prop_table.when_fail)
    if when_fail_type == 'function' or when_fail_type == 'table' then
      add_when_fail(prop_table)
    end

    local it_amount = prop_table.numtests
    local shrink_amount = prop_table.numshrinks
    local numtests = is_integer(it_amount) and it_amount or lqc.numtests
    local numshrinks = is_integer(shrink_amount) and shrink_amount or lqc.numshrinks
    local new_prop = new(descr, prop_table.check, prop_table.generators,
                         numtests, numshrinks)
    table.insert(lqc.properties, new_prop)
  end

  -- property called without DSL-like syntax
  if prop_info_table then
    prop_func(prop_info_table)
    return function() end
  end

  -- property called with DSL syntax!
  return prop_func
end


return property

