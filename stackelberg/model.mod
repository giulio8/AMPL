set A;                          # Azioni disponibili

param U1{A, A};                 # Payoff del leader
param Uf{A, A};                 # Payoff del follower
param AF;                       # Azione seguita dal follower

var sl{A} >= 0;                 # Strategia del leader (distribuzione su A)

maximize obj:
    sum{al in A} U1[al, AF] * sl[al];

subject to cons{af in A}:
    sum{al in A} Uf[al, AF] * sl[al]
    - sum{al in A} Uf[al, af] * sl[al] >= 0;

subject to sumToOneLeader:
    sum{al in A} sl[al] = 1;
