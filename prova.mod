set I;

param U{I, I};

var s{I} >= 0;
var v;

maximize obj: v;

subject to c1{j in I}: v - sum{i in I} U[i, j] * s[i] <= 0;

subject to sumToOne: sum{i in I} s[i] = 1;