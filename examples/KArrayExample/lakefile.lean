import Lake

open Lake DSL System

def leanSrc := "Main.lean" -- can also be a directory
def KArrayTarget := "KArrayFFI.c"

def ffiOTarget (pkgDir : FilePath) : FileTarget :=
  let oFile := pkgDir / defaultBuildDir / "KArrayFFI.o"
  let srcTarget := inputFileTarget <| pkgDir / KArrayTarget
  fileTargetWithDep oFile srcTarget fun srcFile => do
    compileO oFile srcFile
      #["-I", (← getLeanIncludeDir).toString] "c++"

package KArrayExample (pkgDir) {
  dependencies := #[{
    name := `KArray
    src := Source.git "https://github.com/lecopivo/lean4-karray" "master"
  }]
  moreLibTargets := #[
    staticLibTarget (pkgDir / defaultBuildDir / "KArrayFFI.a")
      #[ffiOTarget pkgDir]
  ]
}

script kcompile do
  let packageLib  ← defaultBuildDir / defaultLibDir

  let kArrayBuild ← defaultPackagesDir / "KArray" / defaultBuildDir
  let kArrayLib   ← kArrayBuild / defaultLibDir
  let kArrayBin   ← kArrayBuild / defaultBinDir / "KArray"

  let mathlibBuild ← defaultPackagesDir / "mathlib" / defaultBuildDir
  let mathlibLib   ← mathlibBuild / defaultLibDir

  let runExamples ← IO.Process.output {
    cmd := kArrayBin.withExtension FilePath.exeExtension |>.toString
    args := #[leanSrc, KArrayTarget]
    env := #[("LEAN_PATH", SearchPath.toString [kArrayLib, packageLib, mathlibLib])]
  }
  if runExamples.exitCode ≠ 0 then
    IO.eprint runExamples.stderr
  if runExamples.stdout ≠ "" then
    IO.print runExamples.stdout
  return runExamples.exitCode
