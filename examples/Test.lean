import KArray.KArrayCompile

@[kcompile, extern "c_sqrt_sqrt"] def sqrtSqrt (x : Float) : Float :=
  Float.sqrt (Float.sqrt x)

-- @[kcompile, extern "c_add"] def add (x y : Float) : Float :=
--   x + y

-- this one is skipped
@[kcompile] def mySkippedFun (a b : Float) : Float := a + b

-- this one causes a panic
-- @[kcompile, extern] def test'' (a b : Float) : Float := a + b

def main : IO Unit :=
  IO.println <| sqrtSqrt 16.0
