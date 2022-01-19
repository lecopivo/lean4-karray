#include <lean/lean.h>
#include <math.h>

#define external extern "C" LEAN_EXPORT

external Float c_add(Float x_1,Float x_2);
external Float c_sqrt_sqrt(Float x_1);
external Float c_id(Float x_1);

external Float c_add(Float x_1,Float x_2){
    Float x_3 = Float.add(x_1,x_2);
    Float x_4 = Float.add(x_3,x_2);
    return Float.add(x_1,Float.mul(x_3,x_4));
}

external Float c_sqrt_sqrt(Float x_1){
    return Float.sqrt(Float.sqrt(c_id(x_1)));
}

external Float c_id(Float x_1){
    return x_1;
}
