
sum_up_to = (n) ->
  sum = 0
  for i = 1, n do sum += i
  sum

property 'sum of numbers is equal to (n + 1) * n / 2'
  generators: { int(100) }
  check: (n) -> sum_up_to(n) == (n + 1) * n / 2
  
