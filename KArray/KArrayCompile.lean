import Lean

open Lean

initialize kArrayCompileAttr : TagAttribute ←
  registerTagAttribute `kcompile "tag to request KArray compile"

constant cIncludes : String :=
  "#include <lean/lean.h>"

constant cDefines : String :=
  "#define external extern \"C\" LEAN_EXPORT"

constant semicolon : String := ";"

constant newLine : String := "\n"

constant semicolonNewLine : String := semicolon ++ newLine

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
def mkHeaderAndBody (targetName : Name) (expr : Expr) : String × String :=
  (targetName.toString, expr.dbgToString)

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
            let metaExpr ← mkConst declName
            res ← res.concat $ mkHeaderAndBody targetName metaExpr
            hasProperStandardEntry ← true
            break
        | _ => continue -- non-standard entries are ignored
      if ¬hasProperStandardEntry then
        panic! s!"`kcompile` tag requires `{declName}` to be marked with " ++
          "`extern <targetName>`"
  res

def buildFinalCCode (cHeaders cDecls : List String) : String :=
  cIncludes ++ newLine ++ cDefines ++ newLine ++ -- includes and defines
    semicolonNewLine.intercalate cHeaders ++ semicolonNewLine ++ --headers
    (newLine.intercalate $ (cHeaders.zip cDecls).map λ (a, b) => a ++ b) -- declarations
