import Lean

open Lean

initialize kArrayCompileAttr : ParametricAttribute Name ←
  registerParametricAttribute {
    name := `karray_compile
    descr := "name to be used by code generators"
    getParam := fun _ stx => Attribute.Builtin.getId stx
    afterSet := fun declName _ => do -- TODO: this is not working!
      let mut env ← getEnv
      if env.isProjectionFn declName || env.isConstructor declName then do
        env ← ofExcept $ addExtern env declName
        setEnv env
      else
        pure ()
  }

/- The magic happens here -/
def mkCCode (targetName : Name) (metaExpr : Expr) : String :=
  s!"{targetName}|{metaExpr}"
