import os
from dotenv import load_dotenv
from amplpy import AMPL

# Carica le variabili di ambiente
load_dotenv()

folder_path = "stackelberg"                        

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

# Recupera l'insieme delle azioni possibili
A = list(ampl.getSet("A").getValues())

print(f"🔄 Risoluzione di {len(A)} sottoproblemi per ogni AF...\n")

best_obj = float("-inf")
best_AF = None
best_strategy = {}

# Prova ogni possibile azione del follower
for af in A:
    ampl.getParameter("AF").setValues({af: 1})  # imposta AF = af

    ampl.solve()

    obj_value = ampl.getObjective("obj").value()
    strategy = {int(a): ampl.getVariable("sL")[a].value() for a in A}

    # Stampa i risultati
    print(f"AF = {af} ➜ Obj = {obj_value:.4f}")
    print("   Strategia leader:")
    for al, val in strategy.items():
        print(f"     azione {al}: {val:.4f}")
    print()

    # Aggiorna se migliore
    if obj_value > best_obj:
        best_obj = obj_value
        best_AF = af
        best_strategy = strategy.copy()

# Risultato finale
print("✅ Migliore risposta trovata:")
print(f"   AF = {best_AF}")
print(f"   Obj = {best_obj:.4f}")
print("   Strategia ottima leader:")
for al, val in best_strategy.items():
    print(f"     azione {al}: {val:.4f}")
