local random = require 'lqc.random'
local lqc = require 'lqc.quickcheck'
local Gen = require 'lqc.generator'
local char = require 'lqc.generators.char'
local char_gen = char()


-- NOTE: The shrink algorithms are *heavily* based on triq
--       https://github.com/krestenkrab/triq

-- Helper function to determine how many items to shrink.
local function shrink_how_many(length)
  -- 20% chance more than 1 member is shrunk
  if random.between(1, 5) == 1 then
    return random.between(1, length)
  end
  
  return 1
end

-- Replaces a character in the string 'str' at index 'idx' with 'new_char'.
local function string_replace_char(str, new_char, idx)
  local result = {}
  result[1] = string.sub(str, 1, idx - 1)
  result[2] = new_char
  result[3] = string.sub(str, idx + 1)
  return table.concat(result)
end

-- Replaces 1 character at a random location in the string, tries up to 100
-- times if shrink gave back same result.
local function do_shrink_generic(prev, length, iterations_count)
  local idx = random.between(1, length)
  local old_char = string.sub(prev, idx, idx)
  local new_char = char_gen:shrink(old_char)

  if new_char == old_char and iterations_count ~= 0 then
    -- Shrink introduced no simpler result, retry at other index.
    return do_shrink_generic(prev, length, iterations_count - 1)
  end

  return string_replace_char(prev, new_char, idx)
end

-- Shrinks an amount of characters in the string.
local function shrink_generic(str, length, how_many)
  if how_many ~= 0 then
    local new_str = do_shrink_generic(str, length, lqc.numshrinks)
    return shrink_generic(new_str, length, how_many - 1)
  end

  return str
end

-- Allow shrinking of strings 1/5th of the time (length > 0)
local function should_shrink_smaller(str_len)
  if str_len == 0 then return false end
  return random.between(1, 5) == 1
end

-- Returns a new string with 1 character removed.
local function shrink_smaller(str, str_len)
  local idx = random.between(1, str_len)
  
  -- Handle edge cases (first or last char)
  if idx == 1 then
    return string.sub(str, 2)
  end
  if idx == str_len then
    return string.sub(str, 1, idx - 1)
  end

  local new_str = {
    string.sub(str, 1, idx - 1),
    string.sub(str, idx + 1)
  }
  return table.concat(new_str)
end

-- Generates a string with a specific size.
local function do_generic_pick(size)
  local result = {}
  for _ = 1, size do
    result[#result + 1] = char_gen:pick()
  end
  return table.concat(result)
end

-- Generates a string with arbitrary length (0 <= size <= numtests).
local function arbitrary_length_pick(numtests)
  local size = random.between(0, numtests)
  return do_generic_pick(size)
end

-- Shrinks a string to a simpler form (smaller / different chars).
-- 1. Returns empty strings instantly
-- 2. Determine if string should be made shorter
-- 2.1 if true: remove a char
-- 2.2 otherwise:
--  * simplify a random amount of characters
--  * remove a char if simplify did not help
--  * otherwise return the simplified string
local function arbitrary_length_shrink(prev)
  local length = #prev
  if length == 0 then return prev end  -- handle empty strings

  if should_shrink_smaller(length) then
    return shrink_smaller(prev, length)
  end

  local new_str = shrink_generic(prev, length, shrink_how_many(length))
  if new_str == prev then
    -- shrinking didn't help, remove an element
    return shrink_smaller(new_str, length)
  end

  -- string shrunk succesfully!
  return new_str
end

-- Generates a string with a specific size.
local function specific_length_pick(size)
  local function do_specific_pick()
    return do_generic_pick(size)
  end
  return do_specific_pick
end

-- Shrinks a string to a simpler form (only different chars since length is fixed).
--  * "" -> ""
--  * non-empty string, shrinks upto max 5 chars of the string
local function specific_length_shrink(prev)
  local length = #prev
  if length == 0 then return prev end  -- handle empty strings
  return shrink_generic(prev, length, shrink_how_many(length))
end

-- Generator for a string with an arbitrary size.
local function arbitrary_length_string()
  return Gen.new(arbitrary_length_pick, arbitrary_length_shrink)
end

-- Generator for a string of a specific size.
local function specific_length_string(size)
  return Gen.new(specific_length_pick(size), specific_length_shrink)
end

-- Creates a new ascii string generator
local function new(size)
  if size then
    return specific_length_string(size)
  end

  return arbitrary_length_string()
end

return new

