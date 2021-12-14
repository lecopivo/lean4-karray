import KArray.KArrayCompile

open Lean System

def extractCCodeFromFile (leanFile : FilePath) : IO String := do
  let input ← IO.FS.readFile leanFile
  let (env, ok) ← Lean.Elab.runFrontend input Options.empty leanFile.toString `main
  if ok then
    extractCCodeFromEnv env
  else
    panic! s!"Lean's Frontend failed to run {leanFile}"

partial def getFilePathsList (fp : FilePath) (acc : List FilePath := []) :
IO (List FilePath) := do
  if ← fp.isDir then
    let mut extra : List FilePath ← []
    for dirEntry in (← fp.readDir) do
      for innerFp in ← getFilePathsList dirEntry.path do
        extra ← extra.concat innerFp
    acc ++ extra
  else
    match fp.extension with
    | none => acc
    | some s =>
      if s = "lean" then
        acc.concat fp
      else
        acc

def main (args : List String): IO UInt32 := do
  if args.length = 2 then
    let input : FilePath := ⟨args.get! 0⟩
    -- TODO: improve these validations
    -- validating input target
    if ¬(← input.isDir) then
      match input.extension with
      | none =>
        IO.eprintln "If the input is a file, it must be a lean file"
        return 1
      | some s =>
        if s ≠ "lean" then
          IO.eprintln "If the input is a file, it must be a lean file"
          return 1
    -- validating output target
    let output : FilePath := ⟨args.get! 1⟩
    if (← output.isDir) then
      IO.eprintln "Target output cannot be a directory"
      return 1
    else
      match output.extension with
      | none =>
        IO.eprintln "Target output must be a .cpp file"
        return 1
      | some s =>
        if s ≠ "cpp" then
          IO.eprintln "Target output must be a .cpp file"
          return 1
    let mut cCode ← ""
    Lean.initSearchPath (← Lean.findSysroot?)
    let filePaths ← getFilePathsList $ ⟨args.get! 0⟩
    for filePath in filePaths do
      cCode ← cCode ++ (← extractCCodeFromFile filePath)
    if ¬cCode.isEmpty then
      IO.FS.writeFile output $ cHeader ++ cCode
    return 0
  else
    let appName := (← IO.appPath).fileName.getD "extern"
    IO.eprintln s!"Usage: {appName} <dir or lean-file> <cpp-file>"
    return 1
