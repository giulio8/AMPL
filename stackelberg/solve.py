import os
from dotenv import load_dotenv
from amplpy import AMPL

load_dotenv()

folder_path = "stackelberg"
ampl_path = os.getenv("AMPL_PATH")
model_file = os.path.join(ampl_path, folder_path, "model.mod")
data_file = os.path.join(ampl_path, folder_path, "data-example.dat")

ampl = AMPL()
ampl.option["solver"] = "gurobi"
ampl.read(model_file)
ampl.readData(data_file)

# Estrai solo i valori come tuple native
A_set = ampl.getSet("A")
A_values = [a[0] for a in A_set.getValues()]

best_obj = float("-inf")
best_AF = None
best_strategy = {}

print(f"🔄 Risoluzione di {len(A_values)} sottoproblemi...\n")

for af in A_values:
    ampl.getParameter("AF").set(af)

    ampl.solve()

    obj = ampl.getObjective("obj").value()
    strategy = {a: ampl.getVariable("sl")[a].value() for a in A_values}

    print(f"🔸 AF = {af} ➜ Obj = {obj:.4f}")
    for a, val in strategy.items():
        print(f"   sl({a}) = {val:.4f}")
    print()

    if obj > best_obj:
        best_obj = obj
        best_AF = af
        best_strategy = strategy.copy()

print(f"✅ Migliore AF: {best_AF} con obiettivo {best_obj:.4f}")
