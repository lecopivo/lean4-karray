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

instance : Reflected Float := ⟨"flaot"⟩
instance : Reflected (λ x => Float.sqrt x) := ⟨"sqrt"⟩
instance : Reflected (λ x y => Float.add x y) := ⟨"add"⟩

def typeTranslationList : List (String × String) := [
  ("Float", "double")
]

def functionTranslationList : List (String × String) := [
  ("Float.sqrt", "sqrt")
]

def hashMapFromList (l : List (String × String)) : HashMap String String := Id.run do
  let mut m : HashMap String String ← HashMap.empty
  for (a, b) in l do
    m ← m.insert a b
  m

def typeTranslationHashMap : HashMap String String :=
  hashMapFromList typeTranslationList

def functionTranslationHashMap : HashMap String String :=
  hashMapFromList functionTranslationList

def formattedName (e : Expr) : String :=
  toString e |>.replace "." "_"

def eName (e : Expr) : String :=
  match e.getAppFn.constName? with
  | some n => functionTranslationHashMap.find! n.toString
  | none => formattedName e

/-
# TODO: make sure compiled functions only depend on either:
* functions supported out-of-the-box like add, mul, sqrt, cos etc or
* other compiled functions
-/
partial def toCCode (compilationUnits : List CompilationUnit) (e' : Expr) : MetaM String := do
  match e' with
  | Expr.fvar _ _=> eName e'
  | Expr.letE .. => lambdaLetTelescope e' fun args body => 
    do 
      let mut r := ""
      for i in [0:args.size] do
        let X ← inferType args[i]
        let s ← synthInstance? (← mkAppM `Reflected #[X])
        match s with
        | some _ => 
          -- get and return Reflected.name instead of X.constName
          r := r ++ s!"{X.constName!} {args[i]} = {← toCCode compilationUnits (← whnf args[i])};\n"
        | none => throwError "\nThe type `{X}` of variable `{args[i]}` is not Reflected!\nPlease provide `instance : Reflected {X}`"
      r ++ (← toCCode compilationUnits body)
  | e' => do       
  let e ← whnfI e'  -- only whnfI as we do not want to reduce fvars to their definitions
  let s ← synthInstance? (← mkAppM `Reflected #[e])
  match s with
  | some _ => e.constName!.toString ++ "(" -- get and return Reflected.name instead of e.constName
  | none => do
    match e with
    | Expr.app f x _ => do
      let X ← inferType x
      let s' ← synthInstance? (← mkAppM `Reflected #[X])
      match s' with
      | some _ =>
        let E ← inferType e
        let r ← (← toCCode compilationUnits f) ++ (← toCCode compilationUnits x)
        if E.isForall then 
          r ++ ", "
        else
          r ++ ")"
      | none => throwError "Failed to compile {e}!"
    | _ => throwError "Invalid Expression"

def getArgsTypes (e : Expr) (acc : List String := []) : MetaM (List String) :=
  match e with
  | Expr.lam _ t e' _ => getArgsTypes e' (acc.concat $ toString t)
  | _ => acc

def getArgsNamesAndBody (compilationUnits : List CompilationUnit) (e : Expr) :
MetaM ((List String) × String) :=
  match e with
  | Expr.lam .. => lambdaTelescope e fun args body => do
    (args.data.map formattedName, (← toCCode compilationUnits body))
  | _ => throwError "Function expected!"

def buildArgs (argsTypes argNames : List String) : String :=
  ",".intercalate $ (argsTypes.zip argNames).map λ (type, name) =>
    s!"{typeTranslationHashMap.find! type} {name}"

def getReturnType (declName : Name) : MetaM String := do
  Meta.forallTelescope (← getConstInfo declName).type fun _ type =>
    typeTranslationHashMap.find! $ toString type

def metaCompile (compilationUnits : List CompilationUnit) (declName : Name) :
MetaM (String × String × String) := do
  let metaExpr ← whnf $ mkConst declName
  let argsTypes ← getArgsTypes metaExpr
  let (argNames, body) ← getArgsNamesAndBody compilationUnits metaExpr
  let returnType ← getReturnType declName
  (buildArgs argsTypes argNames, body, returnType)

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
  let cHeaders := cHeadersAndBodies.map λ (h, _) => h
  cIncludes ++ newLine ++ cDefines ++ newLine ++ -- includes and defines
    (semicolonNewLine.intercalate cHeaders ++ semicolonNewLine) ++ --headers
    (newLine.intercalate $ cHeadersAndBodies.map λ (a, b) => a ++ b) -- declarations
