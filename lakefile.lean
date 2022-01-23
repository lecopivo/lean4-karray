import Lake

open Lake DSL System

package KArray {
  supportInterpreter := true
  dependencies := #[{
    name := `mathlib
    src := Source.git "https://github.com/leanprover-community/mathlib4.git" "fe835a1"
  }]
}

script reset do
  let clean ← IO.Process.output {
    cmd := "lake"
    args := #["clean"]
  }
  let cleanCpp ← IO.Process.output {
    cmd := "rm"
    args := #["examples/output.c"]
  }
  return 0

script test do
  let reset ← IO.Process.output {
    cmd := "lake"
    args := #["reset"]
  }
  let build ← IO.Process.output {
    cmd := "lake"
    args := #["build"]
  }
  if build.exitCode ≠ 0 then
    IO.eprintln build.stderr
    return build.exitCode
  let kArrayLib ← defaultBuildDir / defaultLibDir
  let mathlibLib := defaultPackagesDir / "mathlib" / defaultBuildDir / defaultLibDir
  let kArrayPath := defaultBuildDir / defaultBinDir / "KArray"
  let runExamples ← IO.Process.output {
    cmd := kArrayPath.withExtension FilePath.exeExtension |>.toString
    args := #["test", "test/output.c"]
    env := #[("LEAN_PATH", SearchPath.toString [kArrayLib, mathlibLib])]
  }
  if runExamples.exitCode ≠ 0 then
    IO.eprint runExamples.stderr
  if runExamples.stdout ≠ "" then
    IO.print runExamples.stdout
  return runExamples.exitCode
