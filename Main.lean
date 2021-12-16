import KArray.KArrayCompile

open Lean System

def extractCCodeFromFile (leanFile : FilePath) : IO (List (String × String)) := do
  let input ← IO.FS.readFile leanFile
  let (env, ok) ← Lean.Elab.runFrontend input Options.empty leanFile.toString `main
  if ok then
    extractCCodeFromEnv env
  else
    panic! s!"Lean's Frontend failed to run {leanFile}"

def getFilePathExtension (fp : FilePath) : String :=
  match fp.extension with
  | none => ""
  | some s => s

partial def getFilePathsList (fp : FilePath) (acc : List FilePath := []) :
IO (List FilePath) := do
  if ← fp.isDir then
    let mut extra : List FilePath ← []
    for dirEntry in (← fp.readDir) do
      for innerFp in ← getFilePathsList dirEntry.path do
        extra ← extra.concat innerFp
    acc ++ extra
  else
    if (getFilePathExtension fp) = "lean" then
      acc.concat fp
    else
      acc

def main (args : List String): IO UInt32 := do
  if args.length ≠ 2 then
    let appName := (← IO.appPath).fileName.getD "extern"
    IO.eprintln s!"Usage: {appName} <dir or lean-file> <cpp-file>"
    return 1
  else
    let input : FilePath := ⟨args.get! 0⟩
    -- validating input target
    if ¬(← input.isDir) then
      if (getFilePathExtension input) ≠ "lean" then
        IO.eprintln "If the input is a file, it must be a .lean file"
        return 1
    let output : FilePath := ⟨args.get! 1⟩
    -- validating output target
    if (← output.isDir) then
      IO.eprintln "Target output cannot be a directory"
      return 1
    else
      if (getFilePathExtension output) ≠ "cpp" then
        IO.eprintln "Target output must be a .cpp file"
        return 1
    let mut cHeaders : List String ← []
    let mut cDecls : List String ← []
    Lean.initSearchPath (← Lean.findSysroot?)
    for filePath in ← getFilePathsList $ ⟨args.get! 0⟩ do
      for (cHeader, cBody) in ← extractCCodeFromFile filePath do
        cHeaders ← cHeaders.concat cHeader
        cDecls ← cDecls.concat $ cHeader ++ cBody
    if ¬cHeaders.isEmpty then
      IO.FS.writeFile output $ buildFinalCCode cHeaders cDecls
    return 0
