import os
from dotenv import load_dotenv
from amplpy import AMPL

# Carica le variabili dal file .env
load_dotenv()

folder_path = "n-maxmin-polymatrix"

ampl_path = os.getenv("AMPL_PATH")
if ampl_path is None:
    raise ValueError("Please set the AMPL_PATH environment variable in your .env file.")

# Costruisci i path completi dei file
model_file = os.path.join(ampl_path, folder_path, "model.mod")
data_file = os.path.join(ampl_path, folder_path, "data.dat")

ampl = AMPL()  # instantiate AMPL object
ampl.reset()

ampl.read(model_file)  # read the model file
ampl.read(data_file)  # read the data file

ampl.setOption("solver", "gurobi")  # set solver
ampl.solve()  # solve the model

print(ampl.getObjective('obj').value())  # print the objective value
print(ampl.getVariable('v').get_values())  # print the value of variable v
print(ampl.getVariable('s1').get_values())  # print the value of variable s1
print(ampl.getVariable('s2').get_values())  # print the value of variable s2