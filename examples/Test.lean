import KArray.KArray

/-
This is how I thought of the use case: the user writes a definition and marks it with
`karray_compile`. But then needs to define a constant marked with
`extern` "karray_<declName>", which will be the interface to call the compiled code.

A more consistent way to do this would be using `ParametricAttribute` instead of
`TagAttribute`, so the user would be able to say `@[karray_compile "whatever_name"]`
and then mark the constant with `@[extern "whatever_name"]`. That is, name inferring
would be necessary. But unfortunately I wasn't able to make it work :(.
-/

@[karray_compile] def test (a b : Float) : Float := a + b

@[extern "karray_test"] constant kArrayTest (a b : Float) : Float

def main : IO Unit :=
  IO.println <| kArrayTest 21 21
