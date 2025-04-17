set I;

# U1: payoff of player 1 (team) against player 3 (opponent)
param U1{I, I};
# U2: payoff of player 2 (team) against player 3 (opponent)
param U2{I, I};

var s1{I} >= 0;  # strategy of player 1 (team)
var s2{I} >= 0;  # strategy of player 2 (team)
var s3{I} >= 0;  # strategy of player 3 (opponent)
var v;

maximize obj: v;

subject to minOpponent{i in I}:
    v - sum{j in I, k in I} (U1[j,i] + U2[k,i]) * s1[j] * s2[k] <= 0;

subject to sumToOne1:
    sum{j in I} s1[j] = 1;

subject to sumToOne2:
    sum{k in I} s2[k] = 1;

subject to sumToOne3:
    sum{i in I} s3[i] = 1;