import KArray

@[kcompile, extern "c_my_id"] def myId (x : Float) := x

def main : IO Unit :=
  IO.println s!"Hello there!"
