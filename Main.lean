import KArray.KArrayCompile
import Lean.Elab.Frontend

open Lean Meta System

def extractCCode (leanFile : FilePath) : IO String := do
  let mut res ← ""
  let input ← IO.FS.readFile leanFile
  let (env, ok) ← Lean.Elab.runFrontend input Options.empty leanFile.toString `main
  if ok then
    -- TODO: make sure `targetName` is a valid function name for C code
    -- TODO: make sure no `targetName` is repeated
    let externList ← externAttr.ext.getState env |>.toList.map λ t => t.1
    let nameMapList ← kArrayCompileAttr.ext.getState env |>.toList
    for (declName, targetName) in nameMapList do
      if ¬externList.contains declName then
        panic! s!"`extern` tag not found for `{declName}`"
      let metaExpr ← mkConst declName
      res ← res ++ (← mkCCode targetName metaExpr) ++ "\n"
  res

def main (args : List String): IO Unit := do
  -- TODO: iterate on all lean files recursively
  let mut cCode ← ""
  Lean.initSearchPath (← Lean.findSysroot?)
  for fileName in args do
    cCode ← cCode ++ (← extractCCode ⟨fileName⟩)
  if ¬cCode.isEmpty then
    let fullCode ← "#include <lean/lean.h>\n" ++ cCode
    IO.println fullCode
    -- TODO: write a .cpp file containing `fullCode` to disk
    -- this file will be compiled by whoever uses this package as a dependency
