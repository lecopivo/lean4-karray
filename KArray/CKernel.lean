import KArray.Kernel
import KArray.KArray

-- Example of implementing kernel for C runn
namespace CKernel

  inductive type where
    | void : type
    | core_type (name : String) (size : Nat) : type
    | ptr_type : type → type

  def type.name : type → String
    | void => "void"
    | core_type name _ => name
    | ptr_type t => t.name ++ "*"

  -- assuming 64-bit machine
  def type.size : type → Nat
    | void => 8
    | core_type _ size => size
    | ptr_type t => 8

  inductive function where
    | inline_fun (out : type) (args : Array type) (name : String) : function

  def function.name : function → String
    | inline_fun _ _ name => name

  def function.args : function → Array type
    | inline_fun _ args _ => args

  def function.out : function → type
    | inline_fun out _ _ => out

  def void_ptr := type.ptr_type type.void

end CKernel

open CKernel in
def CKernel : Kernel :=
{
  KByteArray := ByteArray
  byteArraySize := ByteArray.size
  byteArrayRead := λ arr i => arr[i]
  malloc := λ size => ByteArray.mkEmpty size -- TODO: This is incorrect! Should be initialize all values to zero?
  malloc_size := sorry -- mkEmpty produces array with zero size - but non zero capacity but we cant argue about it
  
  KType := type
  void := type.void
  ptr := type.ptr_type
  typeDec := sorry  -- I think this there is a way to automatically generate this 
  typeName := λ t => t.name
  typeSize := λ t => t.size

  KFun := function      
  funDec := sorry
  funName := λ f => f.name
  funArgTypes := λ f => f.args
  funOutType := λ f => f.out
  
  null := ⟨void_ptr, #[], "nullptr"⟩
  null_is_ptr := rfl
  null_is_const := rfl

  -- Not sure about this function, maybe `KFun` should be finite list of function and `execute` implements all of them.
  -- Alternativelly, each reflected function provides this.
  execute := sorry
  execute_output := sorry
}

open Kernel CKernel

def cfloat : type := type.core_type  "double" 8

instance : ReflectedType CKernel Float := 
{
  t := cfloat
  readBytes := sorry    -- TODO: provide function that reads double from ByteArray
  writeBytes := sorry   -- TOOO: provide fucntion that writes double from ByteArray

  -- I don't think we can prove these as Lean does not treat Float as 8 UInt8
  write_arr_size := sorry 
  read_write := sorry
  valid_write := sorry
}

instance : ReflectedFun1 CKernel (λ x : Float => x.sqrt) :=
{
  kf := ⟨⟨cfloat, #[cfloat], "sqrt"⟩, rfl, rfl⟩
  -- execute -- probably provide `execute` function here instead of in `Kernel`
  valid := sorry
}

instance : ReflectedFun2 CKernel (λ x y : Float => x + y) :=
{
  kf := ⟨⟨cfloat, #[cfloat, cfloat], "fadd"⟩, rfl, rfl⟩
  -- probably provide `execute` function here instead of in `Kernel`
  -- valid := sorry
}

-- We want to talk about arrays internally with pointers.
-- Do functions `readBytes` and `writeBytes` make sense here??? I'm not so sure 
instance [ReflectedType CKernel α] : ReflectedType CKernel (KArray CKernel α) := 
{
  t := type.ptr_type (ktype (k := CKernel) α)
  readBytes := sorry    -- W
  writeBytes := sorry   -- 

  -- I don't think we can prove these as Lean does not treat Float as 8 UInt8
  write_arr_size := sorry
  read_write := sorry          
  valid_write := sorry

  default := sorry
}
