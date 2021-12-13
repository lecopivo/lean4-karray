import KArray.Kernel

namespace Kernel

structure KArray (k : Kernel) (α : Type) [ReflectedType k α] where
  data : KByteArray k
  valid : data.size % (sizeof k α) = 0

namespace KArray

  variable {α β} [ReflectedType k α] [ReflectedType k β]

  def size (arr : KArray k α) : Nat :=  arr.data.size / (sizeof k α)

  -- turns karray to kbuffer pointing at i-th element
  def toKBuffer (arr : KArray k α) (i : Fin arr.size) : KBuffer k (sizeof k α) :=
    ⟨arr.data, (sizeof k α).toUInt64*i.1.toUInt64, sorry⟩

  -- These functions will me mainly used as a reference implementation and to prove stuff
  def get (arr : KArray k α) (i : Fin arr.size) : α := (arr.toKBuffer i).read α

  def set (arr : KArray k α) (i : Fin arr.size) (a : α) : KArray k α :=
    ⟨(arr.toKBuffer i).write a, sorry⟩


  -- These are the main functions what we care about and where the speed will come from

  -- @[extern "karray_map_fast"]
  def map (kernel : CompiledKExpr k (α → β)) : KArray k α → KArray k β := sorry

  -- @[extern "karray_mapidx_fast"]
  def mapIdx (kernel : CompiledKExpr k (Nat → α → β)) : KArray k α → KArray k β := sorry

  -- @[extern "karray_fold_fast"]
  def fold (kernel : CompiledKExpr k (α → β → β)) : KArray k α → β → β := sorry

end KArray

end Kernel
