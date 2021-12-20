import KArray.KArrayCompile

-- this one is accepted
@[kcompile, extern "c_test"] def foo (x : Float) : Float :=
  Float.sqrt (Float.sqrt x)

-- this one is skipped
@[kcompile] def test' (a b : Float) : Float := a + b

-- this one causes a panic
-- @[kcompile, extern] def test'' (a b : Float) : Float := a + b

def main : IO Unit :=
  IO.println <| foo 16.0
