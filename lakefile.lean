import Lake
open Lake DSL System

package KArray {
  supportInterpreter := true
}

script reset do
  let clean ← IO.Process.output {
    cmd := "lake"
    args := #["clean"]
  }
  let cleanCpp ← IO.Process.output { -- TODO: this is not working
    cmd := "rm"
    args := #["examples/*.cpp"]
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
  let kArrayLib := FilePath.mk "build" / "lib"
  let kArrayPath := FilePath.mk "build" / "bin" / "KArray"
  let runExamples ← IO.Process.output {
    cmd := kArrayPath.withExtension FilePath.exeExtension |>.toString
    args := #["examples", "examples/output.cpp"]
    env := #[("LEAN_PATH", SearchPath.toString [kArrayLib])]
  }
  if runExamples.exitCode ≠ 0 then
    IO.eprint runExamples.stderr
  if runExamples.stdout ≠ "" then
    IO.print runExamples.stdout
  return runExamples.exitCode
