import Lean.Meta

structure Kernel where  
  KByteArray : Type
  byteArraySize : KByteArray → Nat
  byteArrayRead : (arr : KByteArray) → (i : Fin (byteArraySize arr)) → UInt8
  malloc : (size : Nat) → KByteArray
  malloc_size : ∀ n, byteArraySize (malloc n) = n

  KType : Type
  void : KType
  ptr : KType → KType       -- internal way to talk about buffers
  typeDec : DecidableEq KType
  typeName : KType → String
  typeSize : KType → Nat    -- size in bytes

  KFun : Type
  funDec : DecidableEq KFun
  funName : KFun → String
  funArgTypes : KFun → Array KType
  funOutType  : KFun → KType

  null : KFun 
  null_is_ptr   : funOutType null = ptr void
  null_is_const : (funArgTypes null).size = 0

  -- Execute a function
  -- Stack all inputs in the order into a byte array and produce output
  -- This form is mainly used to prove stuff and provide basic runtime
  -- However it is not designed for speed!
  execute : KFun → KByteArray → KByteArray 
  -- Just to make sure the output has the right size
  execute_output : ∀ f input, byteArraySize (execute f input) = typeSize (funOutType f)

instance {k : Kernel} : DecidableEq k.KType := k.typeDec
instance {k : Kernel} : DecidableEq k.KFun := k.funDec

namespace Kernel

  abbrev KByteArray.size {k} (buff : KByteArray k) : Nat := byteArraySize k buff
  abbrev KByteArray.get {k} (buff : KByteArray k) (i : Fin buff.size) : UInt8 := byteArrayRead k buff i

  abbrev KType.name {k} (t : KType k) : String := typeName k t
  abbrev KType.sizeof {k} (t : KType k) : Nat := typeSize k t

  instance {k : Kernel} : Inhabited k.KType := ⟨k.void⟩

  abbrev KFun.outType {k} (f : KFun k) : KType k := funOutType k f
  abbrev KFun.nargs   {k} (f : KFun k) : Nat := (funArgTypes k f).size
  abbrev KFun.argTypes {k} (f : KFun k) : Array (KType k) := (funArgTypes k f)
  abbrev KFun.argType  {k} (f : KFun k) (i : Nat) : KType k := (funArgTypes k f)[i]

  -- This is basically an owning pointer to KByteArray that guarantees `s` bytes
  structure KBuffer (k : Kernel) (s : Nat) where
    arr    : KByteArray k    -- a chunk of memory owned by this `buffer`
    offset : UInt64          -- and ofset specifying where are we pointing
    valid : offset.toNat + s < arr.size  -- assurance of `s` bytes

  -- Typed KFun
  structure KTFun (k : Kernel) (argTypes : Array (KType k)) (outType : KType k) where
    f : KFun k
    valid_args : f.argTypes = argTypes
    valid_out  : f.outType = outType

  def KTFun.sizeofArg {k argTypes outType} (f : KTFun k argTypes outType) : Nat := sorry -- ∑ i, (argTypes.get i).sizeof
  def KTFun.sizeofOut {k inputs output} (f : KTFun k inputs output) : Nat := output.sizeof
  def KTFun.run {k X Y} (f : KTFun k X Y) (input : KByteArray k)
      : KBuffer k Y.sizeof := ⟨execute k f.f input, 0, sorry⟩

  -- This is basically a subset of Lean.Expr
  inductive KExpr (k : Kernel) where
    | bvar  : (i : Nat) → KExpr k
    | const : (f : KFun k) → KExpr k
    | app   : (f : KExpr k) → (arg : KExpr k) → KExpr k

  instance {k} : Inhabited (KExpr k) := ⟨KExpr.const k.null⟩

  class ReflectedType (k : Kernel) (α : Type) extends Inhabited α where
    t : KType k
    readBytes  : (KBuffer k t.sizeof) → α
    writeBytes : (KBuffer k t.sizeof) → α → KByteArray k
    
    -- All of these are imposible to prove, they will be postulated as axioms for every instance
    write_arr_size : ∀ buff a, (writeBytes buff a).size = buff.arr.size
    read_write  : ∀ buff a, readBytes ⟨writeBytes buff a, buff.offset, sorry⟩ = a 
    valid_write : ∀ buff a (i : Fin buff.arr.size), 
                   (i.1 < buff.offset.toNat ∨ i.1 ≥ buff.offset.toNat + t.sizeof) → 
                   (writeBytes buff a).get ⟨i.1, sorry⟩ = buff.arr.get i

  abbrev ktype {k : Kernel} (α : Type) [ReflectedType k α] : KType k := ReflectedType.t α
  abbrev sizeof (k : Kernel) (α : Type) [ReflectedType k α] : Nat := (ktype (k := k) α).sizeof

  def KBuffer.read {k} (α : Type) [ReflectedType k α] (buff : KBuffer k (sizeof k α)) : α :=
    ReflectedType.readBytes buff

  def KBuffer.write {k α} [ReflectedType k α] (buff : KBuffer k (sizeof k α)) (a : α) : KByteArray k :=
    ReflectedType.writeBytes buff a

  def toKBuffer  {α : Type} (k : Kernel) (a : α) [ReflectedType k α] 
      : KBuffer k (sizeof k α) 
      := ⟨ReflectedType.writeBytes ⟨k.malloc (sizeof k α), 0, sorry⟩ a, 0, sorry⟩

  class ReflectedFun1 (k : Kernel) {α β} 
        [ReflectedType k α] [ReflectedType k β] 
        (f : α → β) where
   kf : KTFun k #[ktype  α] (ktype β)
   valid : ∀ (a : α), (kf.run (toKBuffer k a).arr).read β = f a

  class ReflectedFun2 (k : Kernel) {α0 α1 β} 
        [ReflectedType k α0] [ReflectedType k α1] [ReflectedType k β] 
        (f : α0 → α1 → β) where
    kf : KTFun k #[ktype α0, ktype α1] (ktype β)
    -- TODO: define valid for fun2
    -- valid : ∀ (a : α), (kf.run (toKBuffer k a).arr).read β = f a

  -- ReflectedFun3 ... etc. can this be simplified?

  -- Function that takes an `Expr` and tries to produce corresponding `KExpr`
  -- It will some how iterate over the expression and try to fetch instances of `KReflectedFun1` `KReflectedFun2` ...
  open Lean Meta in
  def toKExpr (e : Expr) : MetaM (KExpr k) := sorry

  -- typed KExpr
  structure KTExpr (k : Kernel) (T : Type) where
    kexpr : KExpr k
    -- some kind of proof that `kexpr` correspond to Lean type `T`
  
  -- This will be some object holding a reference to loaded shared library that implements function of type `T`
  constant CompiledKExpr (k : Kernel) (T : Type) : Type 
  
  -- This runs a compiler and dynamically links produced library
  constant compile {T} : KTExpr k T → IO (CompiledKExpr k T)

end Kernel
