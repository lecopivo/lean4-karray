import Lean

open Lean

initialize kArrayCompileAttr : TagAttribute ←
  registerTagAttribute `kcompile "tag to request KArray compile"

constant cHeader : String :=
  "#include <lean/lean.h>\n"

/- The magic happens here -/
def mkCCode (targetName : Name) (expr : Expr) : String :=
  s!"{targetName}|{expr}"

-- TODO: make sure `targetName` is a valid function name for C code
-- TODO: make sure no `targetName` is ever duplicated
def extractCCodeFromEnv (env : Environment) : IO String := do
  let mut res ← ""
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
            res ← res ++ mkCCode targetName metaExpr ++ "\n"
            hasProperStandardEntry ← true
            break
        | _ => continue -- non-standard entries are ignored
      if ¬hasProperStandardEntry then
        panic! s!"`kcompile` tag requires `{declName}` to be marked with " ++
          "`extern <targetName>`"
  res
