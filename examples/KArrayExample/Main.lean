import KArray

-- instances of Reflected can also be provided at user's code
instance : Reflected Float      := ⟨"double"⟩
instance : Reflected Float.sqrt := ⟨"sqrt"⟩
instance : Reflected Float.add  := ⟨"add"⟩
instance : Reflected Float.mul  := ⟨"mul"⟩

@[kcompile, extern "c_id"] def floatId (x : Float) : Float := x

@[kcompile, extern "c_sqrt_sqrt"] def sqrtSqrt (x : Float) : Float :=
  Float.sqrt (Float.sqrt $ floatId x)

@[kcompile, extern "c_some_fun"] def someFun (x y : Float) : Float :=
  let t1 := x + y
  let t2 := t1 + y
  x + t1 * t2

-- this one is skipped because `extern` wasn't used
@[kcompile] def mySkippedFun (a b : Float) : Float := a + b

-- this one causes a panic because no C declaration name is provided
-- @[kcompile, extern] def test'' (a b : Float) : Float := a + b

def main : IO Unit :=
  IO.println <| someFun 16.0 12.0
