import KArray.KArray

@[karray_compile, extern "karray_test"] def test : Float := 21 + 21

def main : IO Unit :=
  IO.println test
