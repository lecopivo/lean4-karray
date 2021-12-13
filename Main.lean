import KArray.KArrayCompile

open Lean System

def extractCCodeFromFile (leanFile : FilePath) : IO String := do
  let input ← IO.FS.readFile leanFile
  let (env, ok) ← Lean.Elab.runFrontend input Options.empty leanFile.toString `main
  if ok then
    extractCCodeFromEnv env
  else
    panic! s!"Lean's Frontend failed to run {leanFile}"

def main (args : List String): IO Unit := do
  -- TODO: iterate on all lean files recursively
  let mut cCode ← ""
  Lean.initSearchPath (← Lean.findSysroot?)
  for fileName in args do
    cCode ← cCode ++ (← extractCCodeFromFile ⟨fileName⟩)
  if ¬cCode.isEmpty then
    let fullCode ← "#include <lean/lean.h>\n" ++ cCode
    IO.println fullCode
    -- TODO: write a karray.cpp file containing `fullCode` to disk
    -- this file would be compiled by whoever uses this package as a dependency
