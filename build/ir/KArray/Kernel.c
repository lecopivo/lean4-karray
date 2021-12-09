// Lean compiler output
// Module: KArray.Kernel
// Imports: Init Lean.Meta
#include <lean/lean.h>
#if defined(__clang__)
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma clang diagnostic ignored "-Wunused-label"
#elif defined(__GNUC__) && !defined(__CLANG__)
#pragma GCC diagnostic ignored "-Wunused-parameter"
#pragma GCC diagnostic ignored "-Wunused-label"
#pragma GCC diagnostic ignored "-Wunused-but-set-variable"
#endif
#ifdef __cplusplus
extern "C" {
#endif
LEAN_EXPORT lean_object* l_Kernel_KFun_argType___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_instInhabited(lean_object*);
LEAN_EXPORT lean_object* l_Kernel_KType_name(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_instDecidableEq__1(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_KTFun_sizeofOut___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_KType_sizeof(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_KBuffer_write(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_KFun_nargs(lean_object*, lean_object*);
static lean_object* l_Kernel_compile___rarg___closed__2;
lean_object* lean_array_get_size(lean_object*);
LEAN_EXPORT lean_object* l_Kernel_sizeof(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_KFun_argType(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_toKBuffer___rarg(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_KBuffer_write___rarg(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_ktype___rarg(lean_object*);
LEAN_EXPORT lean_object* l_Kernel_toKExpr(lean_object*, lean_object*);
static uint32_t l_Kernel_compile___rarg___closed__1;
LEAN_EXPORT lean_object* l_Kernel_KBuffer_read___rarg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_KTFun_run(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_ktype___rarg___boxed(lean_object*);
LEAN_EXPORT lean_object* l_Kernel_KBuffer_read___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_ktype(lean_object*, lean_object*);
lean_object* lean_array_get(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_instDecidableEq__2(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_instInhabited___boxed(lean_object*);
LEAN_EXPORT lean_object* l_Kernel_toKExpr___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_KTFun_sizeofArg(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_KFun_argTypes(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_KFun_outType(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_toKBuffer(lean_object*);
LEAN_EXPORT lean_object* l_Kernel_compile___rarg(lean_object*);
LEAN_EXPORT lean_object* l_Kernel_KTFun_sizeofOut(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_instInhabitedKExpr___boxed(lean_object*);
LEAN_EXPORT lean_object* l_Kernel_KByteArray_size(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_compile___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_toKExpr___rarg(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_KTFun_sizeofArg___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_KByteArray_get(lean_object*, lean_object*, lean_object*);
lean_object* lean_sorry(uint8_t);
static lean_object* l_Kernel_compile___rarg___closed__3;
LEAN_EXPORT lean_object* l_Kernel_KBuffer_read(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_instInhabitedKExpr(lean_object*);
LEAN_EXPORT lean_object* l_Kernel_KBuffer_write___boxed(lean_object*, lean_object*);
uint32_t lean_uint32_of_nat(lean_object*);
LEAN_EXPORT lean_object* l_Kernel_compile(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_KTFun_run___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Kernel_ktype___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_instDecidableEq__1(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
lean_object* x_4; lean_object* x_5; 
x_4 = lean_ctor_get(x_1, 5);
lean_inc(x_4);
lean_dec(x_1);
x_5 = lean_apply_2(x_4, x_2, x_3);
return x_5;
}
}
LEAN_EXPORT lean_object* l_instDecidableEq__2(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
lean_object* x_4; lean_object* x_5; 
x_4 = lean_ctor_get(x_1, 8);
lean_inc(x_4);
lean_dec(x_1);
x_5 = lean_apply_2(x_4, x_2, x_3);
return x_5;
}
}
LEAN_EXPORT lean_object* l_Kernel_KByteArray_size(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; 
x_3 = lean_ctor_get(x_1, 0);
lean_inc(x_3);
lean_dec(x_1);
x_4 = lean_apply_1(x_3, x_2);
return x_4;
}
}
LEAN_EXPORT lean_object* l_Kernel_KByteArray_get(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
lean_object* x_4; lean_object* x_5; 
x_4 = lean_ctor_get(x_1, 1);
lean_inc(x_4);
lean_dec(x_1);
x_5 = lean_apply_2(x_4, x_2, x_3);
return x_5;
}
}
LEAN_EXPORT lean_object* l_Kernel_KType_name(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; 
x_3 = lean_ctor_get(x_1, 6);
lean_inc(x_3);
lean_dec(x_1);
x_4 = lean_apply_1(x_3, x_2);
return x_4;
}
}
LEAN_EXPORT lean_object* l_Kernel_KType_sizeof(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; 
x_3 = lean_ctor_get(x_1, 7);
lean_inc(x_3);
lean_dec(x_1);
x_4 = lean_apply_1(x_3, x_2);
return x_4;
}
}
LEAN_EXPORT lean_object* l_Kernel_instInhabited(lean_object* x_1) {
_start:
{
lean_object* x_2; 
x_2 = lean_ctor_get(x_1, 3);
lean_inc(x_2);
return x_2;
}
}
LEAN_EXPORT lean_object* l_Kernel_instInhabited___boxed(lean_object* x_1) {
_start:
{
lean_object* x_2; 
x_2 = l_Kernel_instInhabited(x_1);
lean_dec(x_1);
return x_2;
}
}
LEAN_EXPORT lean_object* l_Kernel_KFun_outType(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; 
x_3 = lean_ctor_get(x_1, 11);
lean_inc(x_3);
lean_dec(x_1);
x_4 = lean_apply_1(x_3, x_2);
return x_4;
}
}
LEAN_EXPORT lean_object* l_Kernel_KFun_nargs(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; 
x_3 = lean_ctor_get(x_1, 10);
lean_inc(x_3);
lean_dec(x_1);
x_4 = lean_apply_1(x_3, x_2);
x_5 = lean_array_get_size(x_4);
lean_dec(x_4);
return x_5;
}
}
LEAN_EXPORT lean_object* l_Kernel_KFun_argTypes(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; 
x_3 = lean_ctor_get(x_1, 10);
lean_inc(x_3);
lean_dec(x_1);
x_4 = lean_apply_1(x_3, x_2);
return x_4;
}
}
LEAN_EXPORT lean_object* l_Kernel_KFun_argType(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
lean_object* x_4; lean_object* x_5; lean_object* x_6; lean_object* x_7; 
x_4 = lean_ctor_get(x_1, 3);
lean_inc(x_4);
x_5 = lean_ctor_get(x_1, 10);
lean_inc(x_5);
lean_dec(x_1);
x_6 = lean_apply_1(x_5, x_2);
x_7 = lean_array_get(x_4, x_6, x_3);
lean_dec(x_6);
return x_7;
}
}
LEAN_EXPORT lean_object* l_Kernel_KFun_argType___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
lean_object* x_4; 
x_4 = l_Kernel_KFun_argType(x_1, x_2, x_3);
lean_dec(x_3);
return x_4;
}
}
LEAN_EXPORT lean_object* l_Kernel_KTFun_sizeofArg(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4) {
_start:
{
uint8_t x_5; lean_object* x_6; 
x_5 = 0;
x_6 = lean_sorry(x_5);
return x_6;
}
}
LEAN_EXPORT lean_object* l_Kernel_KTFun_sizeofArg___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4) {
_start:
{
lean_object* x_5; 
x_5 = l_Kernel_KTFun_sizeofArg(x_1, x_2, x_3, x_4);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
lean_dec(x_1);
return x_5;
}
}
LEAN_EXPORT lean_object* l_Kernel_KTFun_sizeofOut(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4) {
_start:
{
lean_object* x_5; lean_object* x_6; 
x_5 = lean_ctor_get(x_1, 7);
lean_inc(x_5);
lean_dec(x_1);
x_6 = lean_apply_1(x_5, x_3);
return x_6;
}
}
LEAN_EXPORT lean_object* l_Kernel_KTFun_sizeofOut___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4) {
_start:
{
lean_object* x_5; 
x_5 = l_Kernel_KTFun_sizeofOut(x_1, x_2, x_3, x_4);
lean_dec(x_4);
lean_dec(x_2);
return x_5;
}
}
LEAN_EXPORT lean_object* l_Kernel_KTFun_run(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4, lean_object* x_5) {
_start:
{
lean_object* x_6; lean_object* x_7; uint64_t x_8; lean_object* x_9; 
x_6 = lean_ctor_get(x_1, 13);
lean_inc(x_6);
lean_dec(x_1);
x_7 = lean_apply_2(x_6, x_4, x_5);
x_8 = 0;
x_9 = lean_alloc_ctor(0, 1, 8);
lean_ctor_set(x_9, 0, x_7);
lean_ctor_set_uint64(x_9, sizeof(void*)*1, x_8);
return x_9;
}
}
LEAN_EXPORT lean_object* l_Kernel_KTFun_run___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4, lean_object* x_5) {
_start:
{
lean_object* x_6; 
x_6 = l_Kernel_KTFun_run(x_1, x_2, x_3, x_4, x_5);
lean_dec(x_3);
lean_dec(x_2);
return x_6;
}
}
LEAN_EXPORT lean_object* l_Kernel_instInhabitedKExpr(lean_object* x_1) {
_start:
{
lean_object* x_2; lean_object* x_3; 
x_2 = lean_ctor_get(x_1, 12);
lean_inc(x_2);
x_3 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_3, 0, x_2);
return x_3;
}
}
LEAN_EXPORT lean_object* l_Kernel_instInhabitedKExpr___boxed(lean_object* x_1) {
_start:
{
lean_object* x_2; 
x_2 = l_Kernel_instInhabitedKExpr(x_1);
lean_dec(x_1);
return x_2;
}
}
LEAN_EXPORT lean_object* l_Kernel_ktype___rarg(lean_object* x_1) {
_start:
{
lean_object* x_2; 
x_2 = lean_ctor_get(x_1, 1);
lean_inc(x_2);
return x_2;
}
}
LEAN_EXPORT lean_object* l_Kernel_ktype(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; 
x_3 = lean_alloc_closure((void*)(l_Kernel_ktype___rarg___boxed), 1, 0);
return x_3;
}
}
LEAN_EXPORT lean_object* l_Kernel_ktype___rarg___boxed(lean_object* x_1) {
_start:
{
lean_object* x_2; 
x_2 = l_Kernel_ktype___rarg(x_1);
lean_dec(x_1);
return x_2;
}
}
LEAN_EXPORT lean_object* l_Kernel_ktype___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; 
x_3 = l_Kernel_ktype(x_1, x_2);
lean_dec(x_1);
return x_3;
}
}
LEAN_EXPORT lean_object* l_Kernel_sizeof(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
lean_object* x_4; lean_object* x_5; lean_object* x_6; 
x_4 = lean_ctor_get(x_3, 1);
lean_inc(x_4);
lean_dec(x_3);
x_5 = lean_ctor_get(x_1, 7);
lean_inc(x_5);
lean_dec(x_1);
x_6 = lean_apply_1(x_5, x_4);
return x_6;
}
}
LEAN_EXPORT lean_object* l_Kernel_KBuffer_read___rarg(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; 
x_3 = lean_ctor_get(x_1, 2);
lean_inc(x_3);
lean_dec(x_1);
x_4 = lean_apply_1(x_3, x_2);
return x_4;
}
}
LEAN_EXPORT lean_object* l_Kernel_KBuffer_read(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; 
x_3 = lean_alloc_closure((void*)(l_Kernel_KBuffer_read___rarg), 2, 0);
return x_3;
}
}
LEAN_EXPORT lean_object* l_Kernel_KBuffer_read___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; 
x_3 = l_Kernel_KBuffer_read(x_1, x_2);
lean_dec(x_1);
return x_3;
}
}
LEAN_EXPORT lean_object* l_Kernel_KBuffer_write___rarg(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
lean_object* x_4; lean_object* x_5; 
x_4 = lean_ctor_get(x_1, 3);
lean_inc(x_4);
lean_dec(x_1);
x_5 = lean_apply_2(x_4, x_2, x_3);
return x_5;
}
}
LEAN_EXPORT lean_object* l_Kernel_KBuffer_write(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; 
x_3 = lean_alloc_closure((void*)(l_Kernel_KBuffer_write___rarg), 3, 0);
return x_3;
}
}
LEAN_EXPORT lean_object* l_Kernel_KBuffer_write___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; 
x_3 = l_Kernel_KBuffer_write(x_1, x_2);
lean_dec(x_1);
return x_3;
}
}
LEAN_EXPORT lean_object* l_Kernel_toKBuffer___rarg(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
lean_object* x_4; lean_object* x_5; lean_object* x_6; lean_object* x_7; lean_object* x_8; lean_object* x_9; uint64_t x_10; lean_object* x_11; lean_object* x_12; lean_object* x_13; 
x_4 = lean_ctor_get(x_3, 1);
lean_inc(x_4);
x_5 = lean_ctor_get(x_1, 7);
lean_inc(x_5);
x_6 = lean_apply_1(x_5, x_4);
x_7 = lean_ctor_get(x_3, 3);
lean_inc(x_7);
lean_dec(x_3);
x_8 = lean_ctor_get(x_1, 2);
lean_inc(x_8);
lean_dec(x_1);
x_9 = lean_apply_1(x_8, x_6);
x_10 = 0;
x_11 = lean_alloc_ctor(0, 1, 8);
lean_ctor_set(x_11, 0, x_9);
lean_ctor_set_uint64(x_11, sizeof(void*)*1, x_10);
x_12 = lean_apply_2(x_7, x_11, x_2);
x_13 = lean_alloc_ctor(0, 1, 8);
lean_ctor_set(x_13, 0, x_12);
lean_ctor_set_uint64(x_13, sizeof(void*)*1, x_10);
return x_13;
}
}
LEAN_EXPORT lean_object* l_Kernel_toKBuffer(lean_object* x_1) {
_start:
{
lean_object* x_2; 
x_2 = lean_alloc_closure((void*)(l_Kernel_toKBuffer___rarg), 3, 0);
return x_2;
}
}
LEAN_EXPORT lean_object* l_Kernel_toKExpr___rarg(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4, lean_object* x_5) {
_start:
{
uint8_t x_6; lean_object* x_7; lean_object* x_8; 
x_6 = 0;
x_7 = lean_sorry(x_6);
x_8 = lean_apply_5(x_7, x_1, x_2, x_3, x_4, x_5);
return x_8;
}
}
LEAN_EXPORT lean_object* l_Kernel_toKExpr(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; 
x_3 = lean_alloc_closure((void*)(l_Kernel_toKExpr___rarg), 5, 0);
return x_3;
}
}
LEAN_EXPORT lean_object* l_Kernel_toKExpr___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; 
x_3 = l_Kernel_toKExpr(x_1, x_2);
lean_dec(x_2);
lean_dec(x_1);
return x_3;
}
}
static uint32_t _init_l_Kernel_compile___rarg___closed__1() {
_start:
{
lean_object* x_1; uint32_t x_2; 
x_1 = lean_unsigned_to_nat(0u);
x_2 = lean_uint32_of_nat(x_1);
return x_2;
}
}
static lean_object* _init_l_Kernel_compile___rarg___closed__2() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string("");
return x_1;
}
}
static lean_object* _init_l_Kernel_compile___rarg___closed__3() {
_start:
{
lean_object* x_1; uint32_t x_2; lean_object* x_3; lean_object* x_4; 
x_1 = lean_box(0);
x_2 = l_Kernel_compile___rarg___closed__1;
x_3 = l_Kernel_compile___rarg___closed__2;
x_4 = lean_alloc_ctor(0, 2, 4);
lean_ctor_set(x_4, 0, x_1);
lean_ctor_set(x_4, 1, x_3);
lean_ctor_set_uint32(x_4, sizeof(void*)*2, x_2);
return x_4;
}
}
LEAN_EXPORT lean_object* l_Kernel_compile___rarg(lean_object* x_1) {
_start:
{
lean_object* x_2; lean_object* x_3; 
x_2 = l_Kernel_compile___rarg___closed__3;
x_3 = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(x_3, 0, x_2);
lean_ctor_set(x_3, 1, x_1);
return x_3;
}
}
LEAN_EXPORT lean_object* l_Kernel_compile(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
lean_object* x_4; 
x_4 = lean_alloc_closure((void*)(l_Kernel_compile___rarg), 1, 0);
return x_4;
}
}
LEAN_EXPORT lean_object* l_Kernel_compile___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
lean_object* x_4; 
x_4 = l_Kernel_compile(x_1, x_2, x_3);
lean_dec(x_3);
lean_dec(x_1);
return x_4;
}
}
lean_object* initialize_Init(lean_object*);
lean_object* initialize_Lean_Meta(lean_object*);
static bool _G_initialized = false;
LEAN_EXPORT lean_object* initialize_KArray_Kernel(lean_object* w) {
lean_object * res;
if (_G_initialized) return lean_io_result_mk_ok(lean_box(0));
_G_initialized = true;
res = initialize_Init(lean_io_mk_world());
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_Lean_Meta(lean_io_mk_world());
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
l_Kernel_compile___rarg___closed__1 = _init_l_Kernel_compile___rarg___closed__1();
l_Kernel_compile___rarg___closed__2 = _init_l_Kernel_compile___rarg___closed__2();
lean_mark_persistent(l_Kernel_compile___rarg___closed__2);
l_Kernel_compile___rarg___closed__3 = _init_l_Kernel_compile___rarg___closed__3();
lean_mark_persistent(l_Kernel_compile___rarg___closed__3);
return lean_io_result_mk_ok(lean_box(0));
}
#ifdef __cplusplus
}
#endif
