import Lean

open Lean Meta

initialize kArrayCompileAttr : TagAttribute ←
  registerTagAttribute `kcompile "tag to request KArray compile"

class Reflected (a : α)

-- TODO: Somehow get a proper name
def ename (e : Expr) : String := Id.run do
  match e.getAppFn.constName? with
  | some n => toString n
  | none => toString e

partial def toCCode (e : Expr) : MetaM String := do
  match e with
  | Expr.fvar _ _=> toString e
  | Expr.app f x _ => do
    -- Is `f` reflected?
    let s ← synthInstance? (← mkAppM `Reflected #[f])
    match s with
    | some _ => ename f ++ "(" ++ (← toCCode x) ++ ")"
    | none => do
    (← toCCode f) ++ "(" ++ (← toCCode x) ++ ")"
  | _ => throwError "Invalid Expression"

partial def metaCompile (e : Lean.Expr) : MetaM String := do
  let metaExpr ← whnf e
  match metaExpr with
  | Expr.lam .. => lambdaTelescope metaExpr fun xs b => do (toCCode b)
  | _ => throwError "Function expected!"

instance : Reflected (λ x => Float.sqrt x) := ⟨⟩

/-
The magic happens here.

The header is a string like:
  "external double add(double x, double y)"

Notice that "x" and "y" could be hidden in a header, but it's better to explicit them
so we can reuse the header when defining the function itself.

The body is a string like:
  "{return x + y;}"

# TODO: make sure `targetName` is a valid function name for C code and panic otherwise
# TODO: make sure no `targetName` is ever duplicated
-/
def mkHeaderAndBody (env: Environment) (targetName : Name) (expr : Expr) : IO (String × String) := do
  let header := s!"external double {targetName}()"
  let body ← Prod.fst <$> (metaCompile expr).run'.toIO {} {env}
  (header, body)

def extractCCodeFromEnv (env : Environment) : IO (List (String × String)) := do
  let mut res : List (String × String) ← []
  let externMap ← externAttr.ext.getState env
  for declName in kArrayCompileAttr.ext.getState env do
    match externMap.find? declName with
    | none =>
      IO.println $ s!"Warning: {declName} isn't tagged with `extern`. " ++
        "Skipping KArray compilation."
    | some data =>
      let mut hasProperStandardEntry ← false
      for entry in data.entries do
        match entry with
        | ExternEntry.standard name targetName =>
          let nameString ← name.toString
          if nameString = "all" ∨ nameString = "cpp" then -- this condition suffices
            let expr ← mkConst declName
            res ← res.concat $ ← mkHeaderAndBody env targetName expr
            hasProperStandardEntry ← true
            break
        | _ => continue -- non-standard entries are ignored
      if ¬hasProperStandardEntry then
        panic! s!"`kcompile` tag requires `{declName}` to be marked with " ++
          "`extern <targetName>`"
  res


def cIncludes : String :=
  "#include <lean/lean.h>"

def cDefines : String :=
  "#define external extern \"C\" LEAN_EXPORT"

def semicolon : String := ";"

def newLine : String := "\n"

def semicolonNewLine : String := semicolon ++ newLine

def buildFinalCCode (cHeadersAndBodies : List (String × String)) : String :=
  let cHeaders := cHeadersAndBodies.map λ (h, _) => h
  cIncludes ++ newLine ++ cDefines ++ newLine ++ -- includes and defines
    (semicolonNewLine.intercalate cHeaders ++ semicolonNewLine) ++ --headers
    (newLine.intercalate $ cHeadersAndBodies.map λ (a, b) => a ++ b) -- declarations
