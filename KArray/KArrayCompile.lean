import Lean

open Lean Meta System Std

initialize kArrayCompileAttr : TagAttribute ←
  registerTagAttribute `kcompile "tag to request KArray compile"

structure CompilationUnit where
  filePath   : FilePath
  env        : Environment
  declName   : Name
  targetName : String

class Reflected (a : α) where
  name : String

instance : Reflected Float := ⟨"double"⟩

def formattedName (e : Expr) : String :=
  "x_" ++ (toString e |>.splitOn "." |>.getLast!)

-- TODO: get and return Reflected.name instead
def reflectedName (e : Expr) : MetaM String :=
  e.constName!.toString

-- TODO: compiled functions without reflected instances (replace by their C names)
-- TODO: place "return" properly
partial def toCCode (compilationUnits : List CompilationUnit) (e' : Expr) :
    MetaM String := do
  match e' with
    | Expr.fvar _ _ => formattedName e'
    | Expr.letE ..  => lambdaLetTelescope e' fun args body => do
      let mut r ← ""
      for i in [0 : args.size] do
        let t ← inferType args[i]
        match ← synthInstance? (← mkAppM `Reflected #[t]) with
          | some _ =>
            r ← r ++ s!"{← reflectedName t} " ++ -- type declaration
              s!"{formattedName args[i]} = " ++ -- variable name
              s!"{← toCCode compilationUnits (← whnf args[i])};\n" -- computation
          | none   =>
            throwError s!"The type `{t}` of variable `{args[i]}` is not Reflected!\n" ++
            s!"Please provide `instance : Reflected {t}`"
      r ++ (← toCCode compilationUnits body)
    | e'            =>
      let e ← whnfI e' -- only whnfI as we do not want to reduce fvars to their definitions
      match ← synthInstance? (← mkAppM `Reflected #[e]) with
        | some _ => (← reflectedName e) ++ "("
        | none   =>
          match e with
            | Expr.app f x _ =>
              let t ← inferType x
              match ← synthInstance? (← mkAppM `Reflected #[t]) with
                | some _ =>
                  let r ← (← toCCode compilationUnits f) ++
                    (← toCCode compilationUnits x)
                  if (← inferType e).isForall then r ++ ","
                  else r ++ ")"
                | none   => throwError "Failed to compile `{t}`"
            | _              =>
              let declName : String ← toString e
              for compilationUnit in compilationUnits do
                if declName = toString compilationUnit.declName then
                  return compilationUnit.targetName
              throwError "Invalid Expression `{e}`"

def getArgsTypes (e : Expr) (acc : List Expr := []) : MetaM (List Expr) :=
  match e with
  | Expr.lam _ t e' _ => getArgsTypes e' (acc.concat $ t)
  | _                 => acc

def getArgsNamesAndBody (compilationUnits : List CompilationUnit) (e : Expr) :
MetaM ((List String) × String) :=
  match e with
  | Expr.lam .. => lambdaTelescope e fun args body => do
    (args.data.map formattedName, (← toCCode compilationUnits body))
  | _           => throwError "Function expected!"

def buildArgs (argsTypes : List Expr) (argNames : List String) :
    MetaM String := do
  let mut res : List String ← []
  for (type, name) in argsTypes.zip argNames do
    res ← res.concat s!"{← reflectedName type} {name}"
  ",".intercalate res

def getReturnType (declName : Name) : MetaM String := do
  Meta.forallTelescope (← getConstInfo declName).type
    fun _ type => reflectedName type

def metaCompile (compilationUnits : List CompilationUnit) (declName : Name) :
MetaM (String × String × String) := do
  let metaExpr ← whnf $ mkConst declName
  let argsTypes ← getArgsTypes metaExpr
  let (argNames, body) ← getArgsNamesAndBody compilationUnits metaExpr
  let returnType ← getReturnType declName
  (← buildArgs argsTypes argNames, body, returnType)

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

def validateCompilationUnits (compilationUnits : List CompilationUnit) : IO PUnit := do
  let mut targetNamesSet : HashSet String ← HashSet.empty
  for compilationUnit in compilationUnits do
    if ¬(isValidCFunctionName compilationUnit.targetName) then
      panic! s!"\nError ({compilationUnit.filePath}):\n\tInvalid target name " ++
        s!"'{compilationUnit.targetName}' on declaration `{compilationUnit.declName}`."
    if targetNamesSet.contains compilationUnit.targetName then
      panic! s!"\nError ({compilationUnit.filePath}):\n\tDuplicated occurrence of " ++
        s!"target name '{compilationUnit.targetName}' on declaration `{compilationUnit.declName}`."
    targetNamesSet ← targetNamesSet.insert compilationUnit.targetName

/-
The header is a string like:
  "external double add(double x, double y)"

Notice that "x" and "y" could be hidden in a header, but it's better to explicit them
so we can reuse the header when defining the function itself.

The body is a string like:
  "{return x + y;}"
-/
def processCompilationUnit (compilationUnits : List CompilationUnit)
(compilationUnit : CompilationUnit) : IO (String × String) := do
  let env ← compilationUnit.env
  let (args, body, returnType) ← Prod.fst <$>
    (metaCompile compilationUnits compilationUnit.declName).run'.toIO {} {env}
  let header ← s!"external {returnType} {compilationUnit.targetName}({args})"
  (header, s!"\{\n{body};\n}")

def cIncludes : String :=
  "#include <lean/lean.h>\n" ++
  "#include <math.h>"

def cDefines : String :=
  "#define external extern \"C\" LEAN_EXPORT"

def semicolon : String := ";"

def newLine : String := "\n"

def semicolonNewLine : String := semicolon ++ newLine

def buildFinalCCode (cHeadersAndBodies : List (String × String)) : String :=
  let cHeaders := cHeadersAndBodies.map fun (h, _) => h
  cIncludes ++ newLine ++ cDefines ++ newLine ++ -- includes and defines
    (semicolonNewLine.intercalate cHeaders ++ semicolonNewLine) ++ --headers
    (newLine.intercalate $ cHeadersAndBodies.map fun (a, b) => a ++ b) -- declarations
