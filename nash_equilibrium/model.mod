
set P;  # Players (only 2 players in this case)
set I;  # Actions (same for all players)

param U1{I, I}; # Utility for player 1
param U2{I, I}; # Utility for player 2

param M{P}; # Parameter containing the maximum difference in utility for each player, 
# used to nullify one constraint when some action isn't in the support

var s1{I} >= 0; # Mixed strategy for player 1
var s2{I} >= 0; # Mixed strategy for player 2

var v{P} >= 0; # Value of the game for each player

var b1{I} binary; # Variable for the support of player 1
var b2{I} binary; # Variable for the support of player 2

var epsilon >= 0; # Epsilon for the constraints

# No objective function, we just need to find the equilibrium

subject to cons1_1{i in I}: s1[i] - b1[i] <= 0; # Support constraint for player 1
subject to cons1_2{i in I}: s2[i] - b2[i] <= 0; # Support constraint for player 2

# optionally add epsilon 
subject to cons2_1{i in I}: v[1] - sum{j in I} (U1[i,j] * s2[j]) - M[1] * (1 - b1[i]) - epsilon <= 0; # Player 1's utility constraint (upper)
subject to cons2_2{j in I}: v[2] - sum{i in I} (U2[i,j] * s1[i]) - M[2] * (1 - b2[j]) - epsilon <= 0; # Player 2's utility constraint (upper)

subject to cons3_1{i in I}: v[1] - sum{j in I} (U1[i,j] * s2[j]) >= 0; # Player 1's utility constraint (lower)
subject to cons3_2{j in I}: v[2] - sum{i in I} (U2[i,j] * s1[i]) >= 0; # Player 2's utility constraint (lower)

subject to sumTo1_1: sum{i in I} s1[i] == 1; # Mixed strategy constraint for player 1
subject to sumTo1_2: sum{i in I} s2[i] == 1; # Mixed strategy constraint for player 2

# in the social welfare model, we add the maximization of the sum of utilities
#maximize obj : v[1] + v[2]; # Objective function to maximize the sum of utilities

# in the epsilon nash equilibrium model, we minimize epsilon
minimize obj : epsilon; # Objective function to minimize epsilon