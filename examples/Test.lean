import KArray.KArray

-- TODO: separate this in two declarations
@[karray_compile, extern "karray_test"] def test : Float := 21 + 21

def main : IO Unit :=
  IO.println test
