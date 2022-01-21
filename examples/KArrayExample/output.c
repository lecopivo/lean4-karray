#include <lean/lean.h>
#include <math.h>

#define external extern "C" LEAN_EXPORT

external double c_my_id(double x_1);

external double c_my_id(double x_1){
    return x_1;
}
