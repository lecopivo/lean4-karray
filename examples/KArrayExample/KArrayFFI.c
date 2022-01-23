#include <lean/lean.h>
#include <math.h>

#define external extern "C" LEAN_EXPORT

external double c_some_fun(double x_1, double x_2);
external double c_sqrt_sqrt(double x_1);
external double c_id(double x_1);

external double c_some_fun(double x_1, double x_2){
    double x_3 = add(x_1, x_2);
    double x_4 = add(x_3, x_2);
    return add(x_1, mul(x_3, x_4));
}

external double c_sqrt_sqrt(double x_1){
    return sqrt(sqrt(c_id(x_1)));
}

external double c_id(double x_1){
    return x_1;
}
