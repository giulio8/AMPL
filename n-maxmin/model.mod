set I;

param U{I, I, I};

var s1{I} >= 0;
var s2{I} >= 0;
var v;

maximize obj: v;

subject to constraint{i in I}:
    v - sum{j in I, k in I} U[i,j,k] * s1[j] * s2[k] <= 0;

subject to sumToOneFirst:
    sum{j in I} s1[j] = 1;

subject to sumToOneSecond:
    sum{k in I} s2[k] = 1;
