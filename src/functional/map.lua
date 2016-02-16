
local function map(array, func)
  local result = {}

  for idx = 1, #array do
    result[#result + 1] = func(array[idx])
  end

  return result
end

return map

