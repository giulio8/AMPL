

from amplpy import AMPL


ampl = AMPL() # instantiate AMPL object

ampl.read("prova.mod") # load the model file
ampl.readData("prova.dat") # load the data file
ampl.option["solver"] = "gurobi" # set solver

ampl.solve() # solve the model

print(ampl.getObjective('obj').value()) # print the objective value
print(ampl.getVariable('v').value()) # print the value of variable v
print(ampl.getVariable('s').get_values()) # print the value of variable x