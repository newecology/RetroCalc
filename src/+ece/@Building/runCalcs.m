
 function  runCalcs(obj,config)
 % Runs calculations on the loaded building data
 obj.calcSolarGains;
 obj.calculateWaterDHW();
 obj.calculateApplianceElectricAndGasUse();
 obj.calcDegreeDays;
 obj.calcMonthlyVentilation;
 obj.calcInternalGainsAndElec;
 obj.calcSpaceHeatingEnergy;
 obj.calcSpaceCoolingEnergy;

 % Populate electric usage table with heating and cooling values
 obj.ElectricUsageTable(obj.ElectricUsageTable.electricLoadskWh == "space heating", 2:14) = obj.HeatFuelTable(1, 2:14);
 obj.ElectricUsageTable(obj.ElectricUsageTable.electricLoadskWh == "space cooling", 2:14) = obj.SpaceCoolingTable_kWh(5, 4:16);
 obj.ElectricUsageTable(end, 2:14) = sum(obj.ElectricUsageTable(1:end-1, 2:14));

 %obj.calcEnergyUsage;
 end
