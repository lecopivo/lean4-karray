#include <lean/lean.h>
#define external extern "C" LEAN_EXPORT
external double c_test();
external double c_test(){return test;}