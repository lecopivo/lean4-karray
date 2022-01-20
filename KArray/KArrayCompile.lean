import Lean
import Mathlib.Util.Eval
import Mathlib.Util.TermUnsafe

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

def formattedName (e : Expr) : String :=
  "x_" ++ (toString e |>.splitOn "." |>.getLast!)

open Mathlib.Eval in
def reflectedName (e : Expr) : MetaM String := do
  let e ← (← mkAppOptM `Reflected.name #[none, some $ e, none])
  let f ← unsafe evalExpr String (mkConst `String) e
  return f

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
            throwError s!"Reflected instance of `{t}` is missing."
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
                  if (← inferType e).isForall then r ++ ", "
                  else r ++ ")"
                | none   => throwError "Reflected instance of `{t}` is missing."
            | _              =>
              let declNameStr : String ← toString e
              for compilationUnit in compilationUnits do
                if declNameStr = toString compilationUnit.declName then
                  return compilationUnit.targetName ++ "("
              throwError "Can't find a reference for the compiled version of `{e}`."

def getArgsTypes (e : Expr) (acc : List Expr := []) : MetaM (List Expr) :=
  match e with
  | Expr.lam _ t e' _ => getArgsTypes e' (acc.concat $ t)
  | _                 => acc

def getArgsNamesAndBody (compilationUnits : List CompilationUnit) (e : Expr) :
    MetaM ((List String) × String) :=
  match e with
  | Expr.lam .. => lambdaTelescope e fun args body => do
    (args.data.map formattedName, (← toCCode compilationUnits body))
  | _           => throwError "Failed to compile function `{e}`."

def buildArgs (argsTypes : List Expr) (argNames : List String) :
    MetaM String := do
  let mut res : List String ← []
  for (type, name) in argsTypes.zip argNames do
    match ← synthInstance? (← mkAppM `Reflected #[type]) with
      | some _ => res ← res.concat s!"{← reflectedName type} {name}"
      | none   => throwError "Failed to compile type `{type}`"
  ", ".intercalate res

def getReturnType (declName : Name) : MetaM String := do
  Meta.forallTelescope (← getConstInfo declName).type
    fun _ type => do
      match ← synthInstance? (← mkAppM `Reflected #[type]) with
        | some _ => reflectedName type
        | none   => throwError "Failed to compile type `{type}`"

def formatBody (body : String) : String := Id.run do
  let split ← body.splitOn "\n"
  let splitLength ← split.length
  let mut res : List String := []
  for (i, line) in split.enum do
    if i = splitLength - 1 then
      res ← res.concat $ "    return " ++ line
    else
      res ← res.concat $ "    " ++ line
  "\n".intercalate res

def metaCompile (compilationUnits : List CompilationUnit) (declName : Name) :
    MetaM (String × String × String) := do
  let metaExpr ← whnf $ mkConst declName
  let argsTypes ← getArgsTypes metaExpr
  let (argNames, body) ← getArgsNamesAndBody compilationUnits metaExpr
  let returnType ← getReturnType declName
  (← buildArgs argsTypes argNames, formatBody body, returnType)

def buildMessage (filePath : FilePath) (type msg : String) : String :=
  s!"{type} ({filePath}):\n\t{msg}"

def collectCompilationUnits (filePath : FilePath) : IO (List CompilationUnit) := do
  let input ← IO.FS.readFile filePath
  let (env, ok) ← Lean.Elab.runFrontend input Options.empty filePath.toString `main
  if ok then
    let mut res : List CompilationUnit ← []
    let externMap ← externAttr.ext.getState env
    for declName in kArrayCompileAttr.ext.getState env do
      match externMap.find? declName with
      | none =>
        IO.println $ buildMessage filePath "Warning" s!"`{declName}` isn't marked with " ++
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
          panic! buildMessage filePath "\nError" s!"`kcompile` tag requires `{declName}` " ++
            "to be marked with `extern <targetName>`."
    res
  else
    panic! buildMessage filePath "\nError" s!"Lean's Frontend failed to run."

-- TODO: check if `targetName` is a valid function name for C code
def isValidCFunctionName (targetName : String) : Bool := true

def validateCompilationUnits (compilationUnits : List CompilationUnit) : IO PUnit := do
  let mut targetNamesSet : HashSet String ← HashSet.empty
  for compilationUnit in compilationUnits do
    if ¬(isValidCFunctionName compilationUnit.targetName) then
      panic! buildMessage compilationUnit.filePath "\nError" "Invalid target name " ++
        s!"'{compilationUnit.targetName}' on declaration `{compilationUnit.declName}`."
    if targetNamesSet.contains compilationUnit.targetName then
      panic! buildMessage compilationUnit.filePath "\nError" "Duplicated occurrence of " ++
        s!"target name '{compilationUnit.targetName}' on declaration `{compilationUnit.declName}`."
    targetNamesSet ← targetNamesSet.insert compilationUnit.targetName

def processCompilationUnit (compilationUnits : List CompilationUnit)
    (compilationUnit : CompilationUnit) : IO (String × String) := do
  let env ← compilationUnit.env
  try
    let (args, body, returnType) ← Prod.fst <$>
      (metaCompile compilationUnits compilationUnit.declName).run'.toIO {} {env}
    let header ← s!"external {returnType} {compilationUnit.targetName}({args})"
    (header, s!"\{\n{body};\n}")
  catch | e => panic! buildMessage compilationUnit.filePath "\nError" e.toString

def cIncludes : String :=
  "#include <lean/lean.h>\n" ++
  "#include <math.h>"

def cDefines : String :=
  "#define external extern \"C\" LEAN_EXPORT"

def newLine : String := "\n"

def emptyLine : String := newLine ++ newLine

def semicolonNewLine : String := ";" ++ newLine

def buildFinalCCode (cHeadersAndBodies : List (String × String)) : String :=
  let cHeaders := cHeadersAndBodies.map fun (h, _) => h
  -- includes and defines:
  cIncludes ++ emptyLine ++ cDefines ++ emptyLine ++
  -- headers:
    (semicolonNewLine.intercalate cHeaders ++ semicolonNewLine) ++ newLine ++
  -- declarations:
    (emptyLine.intercalate $ cHeadersAndBodies.map fun (a, b) => a ++ b) ++
  -- an empty line so git doesn't complain about it
    newLine
