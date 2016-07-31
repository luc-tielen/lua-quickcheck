
local function sum_up_to(n)
  local sum = 0
  for i = 1, n do
    sum = sum + i
  end
  return sum
end


property 'sum of numbers is equal to (n + 1) * n / 2' {
  generators = { int(100) },
  check = function(n)
    return sum_up_to(n) == (n + 1) * n / 2
  end
}

