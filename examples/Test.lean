import KArray.KArrayCompile

@[karray_compile c_test] def test (a b : Float) : Float := a + b

def main : IO Unit :=
  IO.println <| test 20 22
