import KArray

open System

partial def getFilePathsList (fp : FilePath) (acc : List FilePath := []) :
IO (List FilePath) := do
  if ← fp.isDir then
    let mut extra : List FilePath ← []
    for dirEntry in (← fp.readDir) do
      for innerFp in ← getFilePathsList dirEntry.path do
        extra ← extra.concat innerFp
    acc ++ extra
  else
    if (fp.extension.getD "") = "lean" then
      acc.concat fp
    else
      acc

def main (args : List String): IO UInt32 := do
  if args.length ≠ 2 then
    let appName := (← IO.appPath).fileName.getD "extern"
    IO.eprintln s!"Usage: {appName} <dir or lean-file> <c-file>"
    return 1
  else
    let input : FilePath := ⟨args.get! 0⟩
    -- validating input target
    if ¬(← input.isDir) then
      if (input.extension.getD "") ≠ "lean" then
        IO.eprintln "If the input is a file, it must be a .lean file"
        return 1
    let output : FilePath := ⟨args.get! 1⟩
    -- validating output target
    if (← output.isDir) then
      IO.eprintln "Target output cannot be a directory"
      return 1
    else
      if (output.extension.getD "") ≠ "c" then
        IO.eprintln "Target output must be a .c file"
        return 1
    Lean.initSearchPath (← Lean.findSysroot?)
    let mut compilationUnits : List CompilationUnit ← []
    for filePath in ← getFilePathsList $ ⟨args.get! 0⟩ do
      compilationUnits ← compilationUnits.append $
        ← collectCompilationUnits filePath
    validateCompilationUnits compilationUnits
    let cBodiesAndHeaders ← compilationUnits.map $ processCompilationUnit compilationUnits
    if ¬cBodiesAndHeaders.isEmpty then
      let mut pureCBodiesAndHeaders : List (String × String) ← []
      for cBodyAndHeader in cBodiesAndHeaders do
        pureCBodiesAndHeaders ← pureCBodiesAndHeaders.concat $ ← cBodyAndHeader
      IO.FS.writeFile output $ ← buildFinalCCode $ pureCBodiesAndHeaders
    return 0
