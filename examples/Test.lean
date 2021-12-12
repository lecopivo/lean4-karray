import KArray.KArray

@[karray_compile] def test : Float := 21 + 21

@[extern "karray_test"] constant kArrayTest : Float

def main : IO Unit :=
  IO.println kArrayTest
