import KArray.KArrayCompile

-- this one is accepted
@[kcompile, extern "c_test"] def test (a b : Float) : Float := a + b

-- this one is skipped
@[kcompile] def test' (a b : Float) : Float := a + b

-- this one causes a panic
-- @[kcompile, extern] def test'' (a b : Float) : Float := a + b

def main : IO Unit :=
  IO.println <| test 20 22
