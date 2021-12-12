import KArray.KArray
-- import KArray.CKernel
import Lean.Elab.Frontend

open Lean System

def extractCCode (leanFile : FilePath) : IO Unit := do
  let input ← IO.FS.readFile leanFile
  let (env, ok) ← Lean.Elab.runFrontend input Options.empty leanFile.toString `main
  if ok then
    for declName in kArrayCompileAttr.ext.getState env do
      -- TODO: make sure no declaration is duplicated
      -- TODO: write a .cpp file instead of printing
      IO.println <| emitCCode env declName |>.toString
  else
    throw $ IO.userError s!"file {leanFile} has errors"

def main (args : List String): IO UInt32 := do
  -- TODO: iterate on all lean files recursively instead of receiving a file as an argument
  if h : 0 < args.length then
    Lean.initSearchPath (← Lean.findSysroot?)
    let file := args.get 0 h
    try
      extractCCode file
      return 0
    catch e =>
      IO.eprintln s!"error: {toString e}"
      return 1
  else
    let appName := (← IO.appPath).fileName.getD "extern"
    IO.eprintln s!"Usage: {appName} lean-file"
    return 1
