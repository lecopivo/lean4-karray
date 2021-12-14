import Lake
open Lake DSL System

package KArray {
  supportInterpreter := true
}

script examples do
  let kArrayLib := FilePath.mk "build" / "lib"
  let kArrayPath := FilePath.mk "build" / "bin" / "KArray"
  let kArrayProcess ← IO.Process.spawn {
    cmd := kArrayPath.withExtension FilePath.exeExtension |>.toString
    args := #["examples", "examples/output.cpp"]
    env := #[("LEAN_PATH", SearchPath.toString [kArrayLib])]
  }
  kArrayProcess.wait
