
--- Module for generating tables of varying sizes and types
-- @module lqc.generators.table
-- @alias new_table

local Gen = require 'lqc.generator'
local random = require 'lqc.random'
local bool = require 'lqc.generators.bool'
local int = require 'lqc.generators.int'
local float = require 'lqc.generators.float'
local string = require 'lqc.generators.string'
local lqc = require 'lqc.quickcheck'
local lqc_gen = require 'lqc.lqc_gen'
local oneof = lqc_gen.oneof
local frequency = lqc_gen.frequency
local deep_equals = require 'lqc.helpers.deep_equals'
local deep_copy = require 'lqc.helpers.deep_copy'


--- Checks if an object is equal to another (shallow equals)
-- @param a first value
-- @param b second value
-- @return true if a equals b; otherwise false
local function normal_equals(a, b)
  return a == b
end


--- Determines if the shrink mechanism should try to reduce the table in size.
-- @param size size of the table to shrink down
-- @return true if size should be reduced; otherwise false
local function should_shrink_smaller(size)
  if size == 0 then return false end
  return random.between(1, 5) == 1
end


--- Determines how many items in the table should be shrunk down
-- @param size size of the table
-- @return amount of values in the table that should be shrunk down
local function shrink_how_many(size)
  -- 20% chance between 1 and size, 80% 1 element.
  if random.between(1, 5) == 1 then
    return random.between(1, size)
  end
  return 1
end


--- Creates a generator for a table of arbitrary or specific size
-- @param table_size size of the table to be generated
-- @return generator that can generate tables
local function new_table(table_size)
  -- Keep a list of generators used in this new table
  -- This variable is needed to share state (which generators) between
  -- the pick and shrink function
  local generators = {}


  --- Shrinks the table by 1 randomly chosen element
  -- @param tbl previously generated table value
  -- @param size size of the table
  -- @return shrunk down table
  local function shrink_smaller(tbl, size)
    local idx = random.between(1, size)
    table.remove(tbl, idx)
    table.remove(generators, idx)  -- also update the generators for this table!!
    return tbl
  end

  --- Shrink a value in the table.
  -- @param tbl table to shrink down
  -- @param size size of the table
  -- @param iterations_count remaining amount of times the shrinking should be retried
  -- @return shrunk down table
  local function do_shrink_values(tbl, size, iterations_count)
    local idx = random.between(1, size)
    local old_value = tbl[idx]
    local new_value = generators[idx]:shrink(old_value)

    -- Check if we should retry shrinking:
    if iterations_count ~= 0 then
      local check_equality = (type(new_value) == 'table')
                           and deep_equals 
                           or normal_equals
      if check_equality(new_value, old_value) then
        -- Shrink introduced no simpler result, retry at other index.
        return do_shrink_values(tbl, size, iterations_count - 1)
      end
    end

    tbl[idx] = new_value
    return tbl
  end

  --- Shrinks an amount of values in the table
  -- @param tbl table to shrink down
  -- @param size size of the table
  -- @param how_many amount of values to shrink down
  -- @return shrunk down table
  local function shrink_values(tbl, size, how_many)
    if how_many ~= 0 then
      local new_tbl = do_shrink_values(tbl, size, lqc.numshrinks)
      return shrink_values(new_tbl, size, how_many - 1)
    end
    return tbl
  end

  --- Generates a random table with a certain size
  -- @param size size of the table to generate
  -- @return tableof a specific size with random values
  local function do_generic_pick(size)
    local result = {}
    for idx = 1, size do
      -- TODO: Figure out a better way to decrease table size rapidly, maybe use
      -- math.log (e.g. ln(size + 1) ?
      local subtable_size = math.floor(size * 0.01)
      local generator = frequency { 
        { 10, new_table(subtable_size) },
        { 90, oneof { bool(), int(size), float(), string(size) } }
      }
      generators[idx] = generator
      result[idx] = generator:pick(size)
    end
    return result
  end


  -- Now actually generate a table:
  if table_size then  -- Specific size
    --- Helper function for generating a table of a specific size
    -- @param size size of the table to generate
    -- @return function that can generate a table of a specific size
    local function specific_size_pick(size)
      local function do_pick()
        return do_generic_pick(size)
      end
      return do_pick
    end

    --- Shrinks a table without removing any elements.
    -- @param prev previously generated table value
    -- @return shrunk down table
    local function specific_size_shrink(prev)
      local size = #prev
      if size == 0 then return prev end -- handle empty tables
      return shrink_values(prev, size, shrink_how_many(size))
    end

    return Gen.new(specific_size_pick(table_size), specific_size_shrink)
  end

  -- Arbitrary size
  
  --- Generate a (nested / empty) table of an arbitrary size.
  -- @param numtests Amount of times the property calls this generator; used to
  --                 guide the optimatization process.
  -- @return table of an arbitrary size
  local function arbitrary_size_pick(numtests)
    local size = random.between(0, numtests)
    return do_generic_pick(size)
  end

  --- Shrinks a table by removing elements or shrinking values in the table.
  -- @param prev previously generated value
  -- @return shrunk down table value
  local function arbitrary_size_shrink(prev)
    local size = #prev
    if size == 0 then return prev end  -- handle empty tables
    
    if should_shrink_smaller(size) then
      return shrink_smaller(prev, size)
    end

    local tbl_copy = deep_copy(prev)
    local new_tbl = shrink_values(tbl_copy, size, shrink_how_many(size))
    if deep_equals(prev, new_tbl) then
      -- shrinking didn't help, remove an element
      return shrink_smaller(prev, size)
    end

    -- table shrunk successfully!
    return new_tbl
  end

  return Gen.new(arbitrary_size_pick, arbitrary_size_shrink)
end


return new_table

