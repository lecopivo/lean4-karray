#include <lean/lean.h>
#include <math.h>
#define external extern "C" LEAN_EXPORT
external double c_sqrt_sqrt(double _uniq_1);
external double c_sqrt_sqrt(double _uniq_1){return sqrt(sqrt(_uniq_1));}