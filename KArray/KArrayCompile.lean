import Lean

open Lean

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
def mkCCode (targetName : Name) (metaExpr : Expr) : String :=
  s!"{targetName}|{metaExpr}"
