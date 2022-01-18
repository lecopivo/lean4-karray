#include <lean/lean.h>
#include <math.h>
#define external extern "C" LEAN_EXPORT
external double c_add(double _uniq_1,double _uniq_2);
external double c_sqrt_sqrt(double _uniq_1);
external double c_add(double _uniq_1,double _uniq_2){
double _uniq_3 = Float.add(_uniq_1,_uniq_2);
double _uniq_4 = Float.add(_uniq_3,_uniq_2);
Float.add(_uniq_1,Float.mul(_uniq_3,_uniq_4));
}
external double c_sqrt_sqrt(double _uniq_1){
Float.sqrt(Float.sqrt(_uniq_1));
}