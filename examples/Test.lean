import KArray.KArrayCompile

-- @[kcompile, extern "c_sqrt_sqrt"] def sqrtSqrt (x : Float) : Float :=
--   Float.sqrt (Float.sqrt x)

-- instances of Reflected can also be provided at user's code
instance : Reflected Float.mul := ⟨"mul"⟩

@[kcompile, extern "c_add"] def add (x y : Float) : Float :=
  let t1 := x + y
  let t2 := t1 + y
  -- let i : Nat := 10 -- this line gives an error as it should
  x + t1 * t2

-- this one is skipped
-- @[kcompile] def mySkippedFun (a b : Float) : Float := a + b

-- this one causes a panic
-- @[kcompile, extern] def test'' (a b : Float) : Float := a + b

def main : IO Unit :=
  IO.println <| add 16.0 12.0
