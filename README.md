# lean4-karray

A WIP package that allows automatic C code generation for functions defined in
Lean.

## Usage

Setup `KArray` according to our [example](examples/KArrayExample). It will allow
you to use the `kcompile` tag in your functions.

The `kcompile` tag needs to be used along with the `extern` tag. Example:

```lean
import KArray

instance : Reflected Float := ⟨"double"⟩

@[kcompile, extern "c_my_fun"] def myFun (x : Float) := x
```

`KArray` will then generate a C file with a function called `c_my_fun`, using
`double` as the reflected type for Lean's `Float`.

You can now run the `kcompile` script to generate the C file:

```bash
$ lake script run kcompile
```

If you create other functions of change the ones tagged with `kcompile`, you
will need to run the script again.

After the C file has been generated and your `lakefile.lean` has been configured,
you're good to call

```bash
$ lake build
```

Which will generate the executable file for your application.
