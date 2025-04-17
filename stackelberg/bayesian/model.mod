set A;      # insieme delle azioni
set T;      # insieme dei tipi del follower

param UI {A, A};          # matrice di utilità del leader (indipendente dal tipo)
param UF {A, A, T};       # matrice di utilità del follower (dipendente dal tipo)
param P {T};              # probabilità dei tipi
param AF {T};             # azione scelta dal follower per ciascun tipo

var sL {A} >= 0;          # strategia mista del leader

maximize obj:
    sum {t in T, al in A}
        P[t] * UI[al, AF[t]] * sL[al];

subject to cons {af in A, t in T}:
    sum {al in A}
        UF[al, AF[t], t] * sL[al]
    - sum {al in A}
        UF[al, af, t] * sL[al]
    >= 0;

subject to sumToOneLeader:
    sum {al in A} sL[al] = 1;
