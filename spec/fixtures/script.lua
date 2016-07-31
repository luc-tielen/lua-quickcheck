
property '+ is commutative' {
  generators = { int(), int() },
  check = function(x, y)
    return x + y == y + x
  end
}

