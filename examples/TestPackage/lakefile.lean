import Lake
open Lake DSL System

package TestKarray {
  dependencies := #[{
    name := `KArray
    src := Source.git "https://github.com/lecopivo/lean4-karray" "master"
  }]
}

script kcompile (args) do
  let packageLib  ← FilePath.mk "build" / "lib"
  let kArrayBuild ← FilePath.mk "lean_packages" / "KArray" / "build"
  let kArrayLib   ← kArrayBuild / "lib"
  let kArrayBin   ← kArrayBuild / "bin" / "KArray"
  let runExamples ← IO.Process.output {
    cmd := kArrayBin.withExtension FilePath.exeExtension |>.toString
    args := args.toArray
    env := #[("LEAN_PATH", SearchPath.toString [kArrayLib, packageLib])]
  }
  if runExamples.exitCode ≠ 0 then
    IO.eprint runExamples.stderr
  if runExamples.stdout ≠ "" then
    IO.print runExamples.stdout
  return runExamples.exitCode
