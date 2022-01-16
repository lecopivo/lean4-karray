# lean4-karray

A WIP package that allows automatic C code generation for functions defined in
Lean.

## Usage

1. Add `KArray` as a dependency of your package:

```lean
package MyPackage {
  dependencies := #[{
    name := `KArray
    src := Source.git "https://github.com/lecopivo/lean4-karray" "master"
  }]
}
```

2. Add the following script to your `lakefile.lean`:

```lean
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
```

3. Build `KArray`:

```bash
$ lake build KArray
```

Now you should be set to use the `kcompile` tag in your functions.

The `kcompile` tag needs to be used along with the `extern` tag. Example:

```lean
import KArray.KArrayCompile

@[kcompile, extern "c_my_fun"] def myFun (x : Float) := Float.sqrt x
```

4. Run the `kcompile script`:

```bash
$ lake run kcompile -- src output.c
```

Where `src` is the directory where your Lean code is located. `KArray` also
accepts a single Lean file as input.

The command above should generate an `output.c` file, which can be compiled
and used with Lean's FFI.

If you create other functions of change the ones tagged with `kcompile`, you
will need to run the script again.
