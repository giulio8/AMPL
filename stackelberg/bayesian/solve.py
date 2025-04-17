import os
from itertools import product
from dotenv import load_dotenv
from amplpy import AMPL

# Setup ambiente
load_dotenv()
folder_path = "stackelberg/bayesian"
ampl_path = os.getenv("AMPL_PATH")
model_file = os.path.join(ampl_path, folder_path, "model.mod")
data_file = os.path.join(ampl_path, folder_path, "data-example.dat")

# Inizializza AMPL
ampl = AMPL()
ampl.option["solver"] = "gurobi"
ampl.read(model_file)
ampl.readData(data_file)

# Estrai insiemi
A = [a[0] for a in ampl.getSet("A").getValues()]
T = [t[0] for t in ampl.getSet("T").getValues()]

# Genera tutti i profili possibili di AF[t] ∈ A^|T|
profiles = list(product(A, repeat=len(T)))

print(f"\n🔄 Risoluzione di {len(profiles)} profili bayesiani AF[t]...\n")

best_obj = float("-inf")
best_AF = None
best_strategy = {}

for prof in profiles:
    current_AF = dict(zip(T, prof))
    for t, af in current_AF.items():
        ampl.getParameter("AF")[t] = af

    ampl.solve()
    obj = ampl.getObjective("obj").value()
    strategy = {a: ampl.getVariable("sL")[a].value() for a in A}
    total = sum(strategy.values())

    # Filtro a posteriori: strategia valida?
    if any(val < -1e-6 for val in strategy.values()):
        continue  # scarta strategia con valori negativi

    if abs(total - 1.0) > 1e-4:
        continue  # scarta strategia che non somma a 1

    print(f"🔸 AF = {current_AF} ➜ Obj = {obj:.4f}")
    for a, val in strategy.items():
        print(f"   sL({a}) = {val:.4f}")
    print()

    if obj > best_obj:
        best_obj = obj
        best_AF = current_AF.copy()
        best_strategy = strategy.copy()

# Risultato finale
if best_AF:
    print("✅ Migliore strategia valida trovata:")
    print(f"   AF = {best_AF}")
    print(f"   Obiettivo massimo = {best_obj:.4f}")
    for a, val in best_strategy.items():
        print(f"   sL({a}) = {val:.4f}")
else:
    print("❌ Nessun profilo AF ha prodotto una soluzione valida.")