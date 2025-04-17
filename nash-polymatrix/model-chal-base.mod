
set P;  # Players (general number of players in this case)
set I;  # Actions (same for all players)

param U{P, P, I, I}; # Utility for player i against player j

param M{P}; # Parameter containing the maximum difference in utility for each player, 
# used to nullify one constraint when some action isn't in the support

var s{P, I} >= 0; # Mixed strategy for player i

var v{P} >= 0; # Value of the game for each player

var b{P, I} binary; # Variable for the support of player i

var epsilon >= 0; # Epsilon for the constraints

# No objective function, we just need to find the equilibrium

# Vincoli di supporto
subject to support{i in P, a in I}:
    s[i,a] - b[i,a] <= 0;

# Vincoli di payoff superiori (con Mi e epsilon)
subject to payoff_upper{i in P, a in I}:
    v[i] - sum{j in P diff {i}, b_j in I} (U[i,j,a,b_j] * s[j,b_j]) - M[i]*(1 - b[i,a]) - epsilon <= 0;

# Vincoli di payoff inferiori
subject to payoff_lower{i in P, a in I}:
    v[i] - sum{j in P diff {i}, b_j in I} (U[i,j,a,b_j] * s[j,b_j]) >= 0;

# Le strategie devono sommare a 1 per ogni giocatore
subject to sum_to_one{i in P}:
    sum{a in I} s[i,a] = 1;
    

# Funzione obiettivo: minimizzare epsilon (ε-Nash)
minimize obj: epsilon;
# in the social welfare model, we add the maximization of the sum of utilities
#maximize obj : v[1] + v[2]; # Objective function to maximize the sum of utilities