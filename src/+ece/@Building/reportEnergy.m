% Displays energy use and internal gains summary
 function reportEnergy(obj)
     disp("Internal Gains Array. Columns are Jan day, Jan night, etc.")
     disp("Rows are 1 sensible, 2 sens and latent, 3 latent, all in kBtu")
     disp(obj.InternalGainsArray_kBtu)
     disp(obj.SpaceHeatingTable_kBtu)
     disp(obj.HeatFuelTable)
     disp(obj.SpaceCoolingTable_kBtu)
     disp(obj.SpaceCoolingTable_kWh)
     disp(obj.ElectricUsageTable)
     disp(obj.BuildingEnergyUsageTable)
 end