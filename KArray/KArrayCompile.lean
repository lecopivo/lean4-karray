import Lean

open Lean Meta System

initialize kArrayCompileAttr : TagAttribute ←
  registerTagAttribute `kcompile "tag to request KArray compile"

structure CompilationUnit where
  filePath   : FilePath
  env        : Environment
  declName   : Name
  targetName : String

class Reflected (a : α)

instance : Reflected (λ x => Float.sqrt x) := ⟨⟩

-- TODO: Somehow get a proper name
def ename (e : Expr) : String := Id.run do
  match e.getAppFn.constName? with
  | some n => toString n
  | none => toString e

/-
# TODO: make sure compiled functions only depend on either:
* functions supported out-of-the-box like add, mul, sqrt, cos etc or
* other compiled functions
-/
partial def toCCode (compilationUnits : List CompilationUnit)
(e : Expr) : MetaM String := do
  match e with
  | Expr.fvar _ _=> toString e
  | Expr.app f x _ => do
    -- Is `f` reflected?
    let s ← synthInstance? (← mkAppM `Reflected #[f])
    match s with
    | some _ => ename f ++ "(" ++ (← toCCode compilationUnits x) ++ ")"
    | none => do
      (← toCCode compilationUnits f) ++ "(" ++ (← toCCode compilationUnits x) ++ ")"
  | _ => throwError "Invalid Expression"

partial def metaCompile (compilationUnits : List CompilationUnit)
(declName : Name) : MetaM String := do
  let metaExpr ← whnf $ mkConst declName
  match metaExpr with
  | Expr.lam .. => lambdaTelescope metaExpr fun xs b => do (toCCode compilationUnits b)
  | _ => throwError "Function expected!"

def collectCompilationUnits (filePath : FilePath) : IO (List CompilationUnit) := do
  let input ← IO.FS.readFile filePath
  let (env, ok) ← Lean.Elab.runFrontend input Options.empty filePath.toString `main
  if ok then
    let mut res : List CompilationUnit ← []
    let externMap ← externAttr.ext.getState env
    for declName in kArrayCompileAttr.ext.getState env do
      match externMap.find? declName with
      | none =>
        IO.println $ s!"Warning ({filePath}):\n\t`{declName}` isn't marked with " ++
          "`extern`. Skipping KArray compilation."
      | some data =>
        let mut hasProperStandardEntry ← false
        for entry in data.entries do
          match entry with
          | ExternEntry.standard name targetName =>
            let nameString ← name.toString
            if nameString = "all" ∨ nameString = "cpp" then -- this condition suffices
              res ← res.concat ⟨filePath, env, declName, targetName⟩
              hasProperStandardEntry ← true
              break
          | _ => continue -- non-standard entries are ignored
        if ¬hasProperStandardEntry then
          panic! s!"\nError ({filePath}):\n\t`kcompile` tag requires `{declName}` to " ++
            "be marked with `extern <targetName>`."
    res
  else
    panic! s!"\nLean's Frontend failed to run `{filePath}`."

-- TODO: check if `targetName` is a valid function name for C code
def isValidCFunctionName (targetName : String) : Bool := true

def countOcurrences (l : List String) (n : String) : IO Nat := do
  let mut c : Nat := 0
  for ni in l do
    if ni = n then
      c := c + 1
  c

def validateCompilationUnits (compilationUnits : List CompilationUnit) : IO PUnit := do
  let targetNames ← compilationUnits.map λ c => c.targetName
  for compilationUnit in compilationUnits do
    if (← countOcurrences targetNames compilationUnit.targetName) > 1 then
      panic! s!"\nError ({compilationUnit.filePath}):\n\tDuplicated occurrence of " ++
        s!"target name '{compilationUnit.targetName}' on declaration `{compilationUnit.declName}`."
    if ¬(isValidCFunctionName compilationUnit.targetName) then
      panic! s!"\nError ({compilationUnit.filePath}):\n\tInvalid target name " ++
        s!"'{compilationUnit.targetName}' on declaration `{compilationUnit.declName}`."

/-
The magic happens here.

The header is a string like:
  "external double add(double x, double y)"

Notice that "x" and "y" could be hidden in a header, but it's better to explicit them
so we can reuse the header when defining the function itself.

The body is a string like:
  "{return x + y;}"
-/
def processCompilationUnit (compilationUnits : List CompilationUnit)
(compilationUnit : CompilationUnit) : IO (String × String) := do
  let header := s!"external double {compilationUnit.targetName}()"
  let env ← compilationUnit.env
  let body ← Prod.fst <$>
    (metaCompile compilationUnits compilationUnit.declName).run'.toIO {} {env}
  (header, s!"\{return {body};}")

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
