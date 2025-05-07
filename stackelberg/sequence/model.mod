# ---------- SETS ----------
set Ql;                # leader sequences
set Qf;                # follower sequences
set Hl;                # leader infosets (include 'Hempty')
set Hf;                # follower infosets (include 'Hempty')

# ---------- PARAMETERS ----------
param Fl{Hl, Ql} >= 0, default 0;
param Ff{Hf, Qf} >= 0, default 0;
param fl{Hl} >= 0;
param ff{Hf} >= 0;

param Ul{Ql, Qf};      # defender utility
param Uf{Qf, Ql};      # attacker utility
param Ml, Mf >= 0;     # big-M values

# ---------- VARIABLES ----------
var r_l{q in Ql} >= 0;         # leader realisation plan
var r_f{q in Qf} binary;       # follower realisation plan (pure)
var z    {Ql, Qf} >= 0;        # bilinear selection vars
var v_f  {h in Hf};            # value of attacker infosets

# ---------- OBJECTIVE ----------
maximize StackelbergPayoff:
      sum {q_l in Ql, q_f in Qf} z[q_l, q_f];

# ---------- CONSTRAINTS ----------

# follower optimality – first (≤) inequality
s.t. FollOpt1 {qf in Qf}:
      sum {hf in Hf} Ff[hf, qf] * v_f[hf]
      - sum {ql in Ql} Uf[qf, ql] * r_l[ql]
      - Mf * (1 - r_f[qf]) <= 0;

# follower optimality – second (≥) inequality
s.t. FollOpt2 {qf in Qf}:
      sum {hf in Hf} Ff[hf, qf] * v_f[hf]
      - sum {ql in Ql} Uf[qf, ql] * r_l[ql] >= 0;

# follower flow / sequence-form consistency
s.t. FollFlow {hf in Hf}:
      sum {qf in Qf} Ff[hf, qf] * r_f[qf] = ff[hf];

# leader flow / sequence-form consistency
s.t. LeadFlow {hl in Hl}:
      sum {ql in Ql} Fl[hl, ql] * r_l[ql] = fl[hl];

# big-M links for z
s.t. z_link_f {ql in Ql, qf in Qf}:
      z[ql, qf] <= r_f[qf] * Ml;

s.t. z_link_l {ql in Ql, qf in Qf}:
      z[ql, qf] <= Ul[ql, qf] * r_l[ql];