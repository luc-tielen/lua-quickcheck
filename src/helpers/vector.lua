
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
end


-- Gets the element at position 'index' in the vector
function Vector:get(index)
  return self.data[index]
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
    if self.data[i] == obj then
      pos = i
      break
    end
  end
  if pos == -1 then return end
  table.remove(self.data, pos)
end

-- Removes an element from the vector by index
function Vector:remove_index(idx)
  table.remove(self.data, idx)
end

-- Returns the vector, with the contents represented as a flat table
function Vector:to_table()
  return self.data
end

return Vector

