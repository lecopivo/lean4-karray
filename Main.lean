import KArray.KArrayCompile
import Lean.Elab.Frontend

open Lean Meta System

def extractCCode (leanFile : FilePath) : IO String := do
  let mut res ← ""
  let input ← IO.FS.readFile leanFile
  let (env, ok) ← Lean.Elab.runFrontend input Options.empty leanFile.toString `main
  if ok then

    -- TODO: adding `extern` tag is not working!
    let testMapList ← externAttr.ext.getState env |>.toList
    IO.println (testMapList.map fun a => a.1)
    
    -- TODO: make sure `targetName` is a valid function name for C code
    let nameMapList ← kArrayCompileAttr.ext.getState env |>.toList
    for (declName, targetName) in nameMapList do
      let metaExpr ← mkConst declName
      res ← res ++ (← mkCCode targetName metaExpr) ++ "\n"
  res

def main (args : List String): IO Unit := do
  -- TODO: iterate on all lean files recursively
  -- TODO: make sure no `targetName` is repeated
  let mut cCode ← ""
  Lean.initSearchPath (← Lean.findSysroot?)
  for fileName in args do
    cCode ← cCode ++ (← extractCCode ⟨fileName⟩)
  if ¬cCode.isEmpty then
    let fullCode ← "#include <lean/lean.h>\n" ++ cCode
    IO.println fullCode
    -- TODO: write a .cpp file containing `fullCode` to disk
    -- this file will be compiled by whoever uses this package as a dependency
