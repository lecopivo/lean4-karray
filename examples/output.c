#include <lean/lean.h>
#include <math.h>
#define external extern "C" LEAN_EXPORT
external double c_add(double _uniq_1,double _uniq_2);
external double c_add(double _uniq_1,double _uniq_2){
Float _uniq.3 = Float.add(_uniq_1, _uniq_2);
Float _uniq.4 = Float.add(_uniq_3, _uniq_2);
Float.add(_uniq_1, Float.mul(_uniq_3, _uniq_4));
}