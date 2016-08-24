local deep_equals = require 'lqc.helpers.deep_equals'

local Vector = {}
local Vector_mt = { 
  __index = Vector
}


-- Constructs a new vector, possibly filled with data (a table value)
function Vector.new(data)
  local begin_data = data or {}
  local vector = { data = begin_data }
  return setmetatable(vector, Vector_mt)
end


-- Adds an element to the back of the vector.
-- Only non-nil values are allowed to the vector; otherwise an error will occur
function Vector:push_back(obj)
  if obj == nil then
    error 'nil is not allowed in vector datastructure!'
  end
  table.insert(self.data, obj)
  return self
end


-- Replaces an element in the vector.
-- Raises an error if idx is an index not present in the vector
function Vector:replace(idx, obj)
  local vec_size = self:size()
  if idx < 1 or idx > vec_size then
    error('Invalid index! Index should be between 1 and ' .. vec_size)
  end
  self.data[idx] = obj
end


-- Appends another vector to this vector
-- Returns the modified vector (self)
function Vector:append(other_vec)
  for i = 1, other_vec:size() do
    self:push_back(other_vec:get(i))
  end
  return self
end


-- Gets the element at position 'index' in the vector
function Vector:get(index)
  return self.data[index]
end


-- Checks if an element is contained in the vector
-- Returns true if the element is already in the vector; otherwise false.
function Vector:contains(element)
  for i = 1, #self.data do
    if self.data[i] == element then return true end
  end
  return false
end

-- Returns the size of the vector. (0 if empty)
function Vector:size()
  return #self.data
end

-- Removes an element from the vector by value
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

-- Removes an element from the vector by index
function Vector:remove_index(idx)
  if idx > self:size() then return end
  table.remove(self.data, idx)
end

-- Returns the vector, with the contents represented as a flat table
function Vector:to_table()
  return self.data
end

return Vector

