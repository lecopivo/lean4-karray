import KArray.KArrayCompile
import Lean.Elab.Frontend

/-
#TODO:
* Make sure every `targetName` is a valid function name for C code
* Make sure no `targetName` is repeated
-/

open Lean Meta System

def extractCCode (leanFile : FilePath) : IO String := do
  let mut res ← ""
  let input ← IO.FS.readFile leanFile
  let (env, ok) ← Lean.Elab.runFrontend input Options.empty leanFile.toString `main
  if ok then
    let nameMapList ← kArrayCompileAttr.ext.getState env |>.toList
    for (declName, targetName) in nameMapList do
      let metaExpr := whnfForall <| mkConst declName
      res ← res ++ mkCCode targetName metaExpr ++ "\n"
  res

def main (args : List String): IO Unit := do
  -- TODO: iterate on all lean files recursively
  let mut cCode ← ""
  Lean.initSearchPath (← Lean.findSysroot?)
  for fileName in args do
    cCode ← cCode ++ (← extractCCode ⟨fileName⟩)
  if ¬cCode.isEmpty then
    IO.println cCode
    let fullCode ← "#include <lean/lean.h>\n" ++ cCode
    -- TODO: write a .cpp file containing `fullCode` to disk
    -- this file will be compiled by whoever uses this package as a dependency
