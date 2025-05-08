#================  STACKELBERG SECURITY GAME on GRID  ========================
# Patroller = leader, Attacker = follower (pure).

# ------------------  AUXILIARY PARAMETERS -------------------
param NROWS > 0;                     # number of rows of the environment grid matrix
param NCOLS > 0;                     # number of columns of the environment grid matrix
set ROWS := 1 .. NROWS;               # rows of the environment grid matrix
set COLS := 1 .. NCOLS;               # columns of the environment grid matrix

param grid{ROWS, COLS} binary; # grid matrix (i,j) = white node label

set TARGETS within {ROWS, COLS}; # targets (i,j)

# ---------- SETS & INDICES --------------------------------------------------
set V := {r in ROWS, c in COLS : grid[r,c] = 1};          # real traversable V
param TMAX > 0;                        # horizon
set T0 := 0 .. TMAX-1;                 # times where moves originate
set T1 := 1 .. TMAX;                   # times where attacks are possible

set S0 := {(-1, -1)};                     # fictitious start node label
set NODES := V union S0;         # includes start

# Neighbourhood: predecessor relation  ((rp, cp) is predecessor of v)
######################################################################

# Vettori spostamento che identificano le 4 adiacenze ortogonali
set SHIFT := { (0, 0), (-1, 0), (1, 0), (0, -1), (0, 1) };

set SPAWN := { (1,4), (4,2), (4,7), (7,4) };

######################################################################
# "Funzione" AMPL: per ogni (i,j) restituisce il set dei nodi adiacenti
######################################################################
set NEIGH { (i,j) in NODES } :=
    if (i = -1) and (j = -1)
        then SPAWN 
        else
    setof { (di,dj) in SHIFT :
            1 <= i+di <= NROWS  &&
            1 <= j+dj <= NCOLS  &&
            grid[i+di,j+dj] = 1
            }  (i+di, j+dj);

/* set PRED { (i,j) in V } :=
    S0 union
    setof { (di,dj) in SHIFT :
            1 <= i+di <= NROWS  &&
            1 <= j+dj <= NCOLS  &&
            grid[i+di,j+dj] = 1
            }  (i+di, j+dj); */


# ---------- PAYOFF PARAMETERS - NOW CHANGES WITH TIME ----------------------------------------------
param RD_capture{TARGETS, T1};                # defender reward if capture
param RA_capture{TARGETS, T1};                # attacker reward if capture
param RD_no_capture{TARGETS, T1};                # defender reward if not capture
param RA_no_capture{TARGETS, T1};                # attacker reward if not capture



param MATTACK :=
      max {(r,c) in TARGETS, t in T1}
          ( max(abs(RA_capture[r,c,t]), abs(RA_no_capture[r,c,t])) );

# ---------- VARIABLES -------------------------------------------------------
var alpha{(r,c) in V, (rp,cp) in NODES, t in T0} >= 0;   # realisation plan
var p{(r,c) in V, t in T1} >= 0;                # occupancy (explicit)

var attack{(rt, ct) in TARGETS, t in T1} binary;        # follower choice
var UA;                                              # attacker exp. util
var UD;                                              # defender exp. util

# Auxiliary: attacker util for each (theta,t)
var u_theta{(rt, ct) in TARGETS, t in T1};

# ---------- OCCUPANCY EXTRACTION -------------------------------------------
s.t. OccExtract { (r,c) in V, t in 1..TMAX-1 }:
    p[r,c,t] = sum{ (rp,cp) in NEIGH[r,c] } alpha[r,c,rp,cp,t];

s.t. OccFinal { (r,c) in V }:
    p[r,c,TMAX] = sum{ (rp,cp) in NEIGH[r,c] } alpha[r,c,rp,cp,TMAX-1];

/* s.t. OccStart:
    p[-1,-1,0] = 1; */

s.t. OccTotalSum1 { t in T1 }:
    sum{ (r,c) in V } p[r,c,t] = 1;

/* s.t. NoReturnWorking { t in T1}:
    p[-1,-1,t] = 0; */

# ---------- FLOW CONSERVATION ----------------------------------------------
s.t. Flow { (r,c) in V, t in 0..TMAX-2 }:
    sum{ (rp,cp) in NEIGH[r,c] } alpha[r,c,rp,cp,t]
  = sum{ (nr,nc) in NEIGH[r,c] } alpha[nr,nc,r,c,t+1];

# total sum of probabilities at time t
/* s.t. AlphaTotalSum { (r,c) in V, t in T0 }:
    sum{ (rp,cp) in PRED[r,c] } alpha[r,c,rp,cp,t] = 1; */

# ---------- STARTING FROM S0 ONLY AT t=0 -----------------------------------
s.t. StartProb:
    sum{ (r,c) in V } alpha[r,c,-1,-1,0] = 1;

 s.t. NoReturn { (r,c) in V, t in 1..TMAX-1 }:
    alpha[r,c,-1,-1,t] = 0; 

# ---------- ATTACKER CHOOSES *EXACTLY* ONE ACTION ---------------------------
s.t. SingleAttack:
      sum{(rt, ct) in TARGETS, t in T1} attack[rt, ct,t] = 1;

# ---------- INSTANT UTILITY OF EACH ((rt, ct),t) -- *attacker*  ---------------
s.t. Define_u {(rt, ct) in TARGETS, t in T1}:
      u_theta[rt, ct,t] =
            p[rt, ct,t]   * RA_capture[rt, ct, t]
          + (1 - p[rt, ct,t]) * RA_no_capture[rt, ct, t];

# ---------- ATTACKER BEST RESPONSE (big-M linearisation) --------------------
s.t. BR_upper {(rt, ct) in TARGETS, t in T1}:
      UA >= u_theta[rt, ct,t];

s.t. BR_link  {(rt, ct) in TARGETS, t in T1}:
      UA <= u_theta[rt, ct,t] + MATTACK * (1 - attack[rt, ct,t]);

# ---------- DEFENDER UTILITY DEFINITION  ------------------------------------
s.t. DefenderUtil:
      UD = sum{(rt, ct) in TARGETS, t in T1}
             attack[rt, ct,t] *
             (   p[rt, ct,t]   * RD_capture[rt, ct, t]
               + (1 - p[rt, ct,t]) * RD_no_capture[rt, ct, t] );

# ---------- OBJECTIVE -------------------------------------------------------
maximize LeaderPayoff: UD;
