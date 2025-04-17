set P;             # Insieme dei giocatori: {1, ..., n}
set I;             # Azioni disponibili per ogni giocatore
param n symbolic;  # Identificatore del giocatore avversario

# U[i,a_i,a_n] è il payoff del giocatore i (i ≠ n) contro l’avversario n
param U{P, I, I};  # U[i, a_i, a_n]

# Strategie miste
var s{P, I} >= 0;  # Strategia del giocatore i sull'azione a
var v;             # Valore minimo garantito dal team

# Obiettivo: massimizzare il valore minimo garantito dal team contro il giocatore n
maximize obj: v;

# Vincolo: min dell’avversario (giocatore n) sulle strategie indipendenti
subject to minOpponent{a_n in I}:
    v - sum{i in P diff {n}, a_i in I} U[i,a_i,a_n] * s[i,a_i] <= 0;

# Vincoli: strategie sommano a 1
subject to sumToOne{i in P}:
    sum{a in I} s[i,a] = 1;