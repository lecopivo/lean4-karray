import Lean

open Lean

/-
Usage example:
```
import KArray.KArray

@[karray_compile c_test] def test (a b : Float) : Float := a + b

def main : IO Unit :=
  IO.println <| test 21 21
```
-/
initialize kArrayCompileAttr : ParametricAttribute Name ←
  registerParametricAttribute {
    name := `karray_compile
    descr := "name to be used by code generators"
    getParam := fun _ stx => Attribute.Builtin.getId stx
    afterSet := fun declName _ => do
      let env ← ofExcept $ addExtern (← getEnv) declName
      setEnv env
  }

/- The magic happens here -/
def mkCCode (targetName : Name) (metaExpr : MetaM Expr) : String := ""