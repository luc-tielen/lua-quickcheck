
--- Module for a data container that does not allow nil values.
-- @classmod lqc.helpers.vector
-- @alias Vector

local deep_equals = require 'lqc.helpers.deep_equals'

local Vector = {}
local Vector_mt = {
  __index = Vector
}


--- Constructs a new vector, possibly filled with data (a table value)
-- @param data[opt={}] the data to be stored in the vector initially
-- @return a new vector filled with the initial data if provided.
function Vector.new(data)
  local begin_data = data or {}
  local vector = { data = begin_data }
  return setmetatable(vector, Vector_mt)
end


--- Adds an element to the back of the vector.
-- @param obj a non-nil value
-- @return self (for method chaining); raises an error if trying to add nil to the vector
function Vector:push_back(obj)
  if obj == nil then
    error 'nil is not allowed in vector datastructure!'
  end
  table.insert(self.data, obj)
  return self
end


--- Replaces an element in the vector.
-- @param idx Index of the element in the vector to be replaced
-- @param obj Object that the previous object should be replaced with
-- @return self (for method chaining); raises an error if idx is an index
--         not present in the vector
function Vector:replace(idx, obj)
  local vec_size = self:size()
  if idx < 1 or idx > vec_size then
    error('Invalid index! Index should be between 1 and ' .. vec_size)
  end
  self.data[idx] = obj
  return self
end


--- Appends another vector to this vector
-- @param other_vec Another vector object
-- @return a vector containing the data of both vectors
function Vector:append(other_vec)
  for i = 1, other_vec:size() do
    self:push_back(other_vec:get(i))
  end
  return self
end


--- Gets the element at position 'index' in the vector
-- @param index position of the value in the vector
-- @return element at position 'index
function Vector:get(index)
  return self.data[index]
end


--- Checks if an element is contained in the vector
-- @param element element to be checked if it is in the vector
-- @return true if the element is already in the vector; otherwise false.
function Vector:contains(element)
  for i = 1, #self.data do
    if self.data[i] == element then return true end
  end
  return false
end


--- Returns the size of the vector.
-- @return length of the vector (0 if empty)
function Vector:size()
  return #self.data
end


--- Removes an element from the vector by value
-- @param obj object to remove
function Vector:remove(obj)
  -- Find element, then remove by index
  local pos = -1
  for i = 1, #self.data do
    if deep_equals(self.data[i], obj) then
      pos = i
      break
    end
  end
  if pos == -1 then return end
  table.remove(self.data, pos)
end


--- Removes an element from the vector by index
-- @param idx Position of the element you want to remove
function Vector:remove_index(idx)
  if idx > self:size() then return end
  table.remove(self.data, idx)
end

--- Returns the vector, with the contents represented as a flat table
-- @return Table with the contents of the vector
function Vector:to_table()
  return self.data
end


return Vector

