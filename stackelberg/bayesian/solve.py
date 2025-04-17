import os
from itertools import product
from dotenv import load_dotenv
from amplpy import AMPL

# Carica le variabili dal file .env
load_dotenv()

folder_path = "nash_equilibrium"                        

ampl_path = os.getenv("AMPL_PATH")
if ampl_path is None:
    raise ValueError("Please set the AMPL_PATH environment variable in your .env file.")

model_file = os.path.join(ampl_path, folder_path, "model.mod")
data_file = os.path.join(ampl_path, folder_path, "data.dat")

# Inizializza AMPL
ampl = AMPL()
ampl.option["solver"] = "gurobi"
ampl.read(model_file)
ampl.readData(data_file)

# Recupera insiemi A e T
A = list(ampl.getSet("A").getValues())
T = list(ampl.getSet("T").getValues())

# Genera tutte le combinazioni possibili di AF[t]
# Ogni AF è un dizionario tipo: {"type1": 1, "type2": 3}
action_profiles = list(product(A, repeat=len(T)))

print(f"🔄 Risoluzione di {len(action_profiles)} sottoproblemi...\n")

best_obj = float("-inf")
best_AF = None
best_strategy = {}

# Itera su ogni possibile profilo AF
for profile in action_profiles:
    # Costruisci dizionario AF
    AF_dict = {t: a for t, a in zip(T, profile)}

    # Imposta AF in AMPL
    for t, a in AF_dict.items():
        ampl.getParameter("AF")[t] = a

    # Risolvi
    ampl.solve()

    # Recupera l'obiettivo e strategia ottima
    obj_value = ampl.getObjective("obj").value()
    strategy = {int(al): ampl.getVariable("sL")[al].value() for al in A}

    # Stampa i risultati
    print(f"AF: {AF_dict} ➜ Obj = {obj_value:.4f}")
    print("   Strategia leader:")
    for al, val in strategy.items():
        print(f"     azione {al}: {val:.4f}")
    print()

    # Salva se è la migliore
    if obj_value > best_obj:
        best_obj = obj_value
        best_AF = AF_dict.copy()
        best_strategy = strategy.copy()

# Stampa la migliore
print("✅ Migliore profilo trovato:")
print(f"   AF: {best_AF}")
print(f"   Obj = {best_obj:.4f}")
print("   Strategia ottima leader:")
for al, val in best_strategy.items():
    print(f"     azione {al}: {val:.4f}")
