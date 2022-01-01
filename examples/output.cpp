#include <lean/lean.h>
#include <math.h>
#define external extern "C" LEAN_EXPORT
external double c_sqrt_sqrt(double _uniq_2);
external double c_sqrt_sqrt(double _uniq_2){return sqrt(sqrt(_uniq_2));}