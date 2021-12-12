import KArray.KArray

@[karray_compile] def test (a b : Float) : Float := a + b

@[extern "karray_test"] constant kArrayTest (a b : Float) : Float

def main : IO Unit :=
  IO.println <| kArrayTest 21 21
