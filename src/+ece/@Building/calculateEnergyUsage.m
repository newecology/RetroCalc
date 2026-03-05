function calculateEnergyUsage(obj)
% CALCULATEENERGYUSAGE Method to compute the total energy usage for a
% Building; synonymous with evaluating the Level 2 Energy result.
% This function sums up usage of gas, oil, and propane from heating, DHW,
% and any gas using appliances. Other fuels could be added, such as district
% steam, diesel fuel, or wood.
% Add total building electric use as the first line of the output table.
% Building electric use hase been summed in the ElectricUsageTable.
% Each row will represent a month, with the final row being the
% annual roll-up of all months.

% Updating the ElectricUsageTable with space cooling and space heating
obj.ElectricUsageTable.SpaceCooling = obj.SpaceCoolingTable_kWh{end,4:16}';
obj.ElectricUsageTable.SpaceHeating = obj.HeatFuelTable.Electricity_kWh;

% Update the totals column to include the space heat/cool kWh.
obj.ElectricUsageTable = removevars(obj.ElectricUsageTable, "MonthlyTotals");
obj.ElectricUsageTable.MonthlyTotals = ...
    sum(obj.ElectricUsageTable{:, 2:11}, 2);

% Instantiate Energy Matrix
energy12 = zeros(13, 5);

% Total building electric usage for 12 months.
energy12(1:12,1) = obj.ElectricUsageTable{1:12, end};

% Space heating fuel use
heatGas12_therms = obj.HeatFuelTable.Gas_therms(1:12);
heatOil12_gallons = obj.HeatFuelTable.HeatingOil_gallons(1:12);
heatPropane12_gallons = obj.HeatFuelTable.Propane_gallons(1:12);

% DHW fuel use
DHWgas12_therms = obj.DHWfuelTable{obj.DHWfuelTable.DHWfuelType == ...
    "Gas_therms", 2:13}';
DHWoil12_gallons = obj.DHWfuelTable{obj.DHWfuelTable.DHWfuelType == ...
    "HeatingOil_gallons", 2:13}';
DHWpropane12_gallons = obj.DHWfuelTable{obj.DHWfuelTable.DHWfuelType == ...
    "Propane_gallons", 2:13}';

% Appliance fuel use
applGas12_therms = table2array(obj.ApplianceEnergyTable12(2, :))';
% Add line for appliances operating on propane
applPropane12_gallons = zeros(12, 1);

% Add the usage for each fuel type and make a table with monthly and annual
% totals. Bottom row of the table sums the kBtu of all the energy types.
buildingEnergyUseVarNames = ["Electricity_kWh", "Gas_therms",...
    "HeatingOil_gallons","Propane_gallons","Totals_kBtu"];

energy12(1:12,2:4) = [...
    heatGas12_therms + DHWgas12_therms + applGas12_therms, ...
    heatOil12_gallons + DHWoil12_gallons,...
    heatPropane12_gallons + DHWpropane12_gallons + applPropane12_gallons];

energy12(:,end) = energy12(:,1) * 3413/1000 + ...
    energy12(:,2) * 100 + ...
    energy12(:,3) * 138500/1000 + ...
    energy12(:,4) * 91500/1000;

energy12(13,:) = sum(energy12(1:12,:), 1);

% Create Month Column for All Usages
usageTablePeriods = ["January","February","March","April","May","June",...
    "July","August","September","October","November","December",...
    "Annual"]';

% Build Usage Table
usageTable = array2table(energy12, ...
    "VariableNames", buildingEnergyUseVarNames);
usageTable = addvars(usageTable,...
    usageTablePeriods,...
    'Before', 1,...
    'NewVariableNames',"Period");

% Write table to building.
obj.BuildingEnergyUsageTable = usageTable;

%% Create Level 2 KeyResults Object
% Make a table of the key parameters or statistics that are used for
% calibration and for comparing one package to another. Write to 
% Building.Level2.
% All numbers are per year.

% The parameters for HEA and Level2 are identical and listed in KeyResults class.
% The results of the level 2 calculation are written to Building.Level2 but some
% of the parameters are taken from the HEA.
% For example the unit costs of the utilities are from the HEA, and are
% then applied to the calculated usage for each utility type to determine
% annual cost.
% KeyResults parameters
% 1 Electricity_kWh           Total electricity use, kWh
% 2 Gas_therms                Total gas use, therms
% 3 Water_gallons             Total water use, gallons
% 4 Oil_gallons               Total oil use, gallons
% 5 Propane_gallons           Total propane use, gallons
% 6 EUI                       Energy use index, kBtu/ft2
% 7 AnnualCostOfElectricity   Total annual cost of electricity, dollars
% 8 UnitCostOfElectricity     Cost of electricity per kWh, most recent year
% 9 AnnualCostOfGas
% 10 UnitCostOfGas
% 11 AnnualCostOfWater
% 12 UnitCostOfWater
% 13 AnnualCostOfOil
% 14 UnitCostOfOil
% 15 AnnualCostOfPropane
% 16 UnitCostOfPropane
% 17 AnnualCostTotal           Total cost of all utilities
% 18 CO2e                      CO2 equivalent emissions, kg / ft2 floor area
% 19 WaterResidential_gallons  Residential water use gallons (excludes irrigation, cooling tower, etc.)
% 20 WaterNonResidential_gallons Water use for irrigation, cooling tower, etc., gallons
% 21 Water_GPDBedroom          Water residential gallons per day per bedroom.
% 22 SpaceHeat_kWh
% 23 SpaceHeatGas_therms
% 24 SpaceHeatOil_kBtu
% 25 SpaceHeatPropane_gallons
% 26 SpaceHeat_kBtuFt2         EUI for space heating only, kBtu/ft2
% 27 SpaceCool_kWh             
% 28 SpaceCool_kBtuFt2         EUI for space cooling only, kBtu/ft2
% 29 DHW_kWh
% 30 DHWGas_therms
% 31 DHWOil_kBtu
% 32 DHWPropane_gallons
% 33 DHW_kBtuFt2               EUI for DHW only, kBtu/ft2
% 34 NonHVACelec_kBtuFt2       Electricity for lights/plug loads/appliances/fans/pumps (no heating, cooling, DHW)
% 35 ApplianceFuel_kBtuFt2     Gas or propane use for appliances, kBtu (excludes electricity)

area = obj.GrossConditionedArea_ft2;
numBRs = sum(obj.NumberOfBedroomUnits .* [1, 2, 3, 4]);

% -- Utility Usages
% Electric Usage
obj.Level2.Electricity_kWh = ...
    obj.BuildingEnergyUsageTable.Electricity_kWh(end);
% Gas Usage
obj.Level2.Gas_therms = ...
    obj.BuildingEnergyUsageTable.Gas_therms(end);
% Water Usage
obj.Level2.Water_gallons = ...
    obj.WaterUsageTable.Annual(obj.WaterUsageTable.waterGallons == "Totals");
% Oil Usage
obj.Level2.Oil_gallons = ...
    obj.BuildingEnergyUsageTable.HeatingOil_gallons(end);
% Propane Usage
obj.Level2.Propane_gallons = ...
    obj.BuildingEnergyUsageTable.Propane_gallons(end);

% EUI by Area
obj.Level2.EUI = obj.BuildingEnergyUsageTable.Totals_kBtu(end) / area;

% Annual cost of each utility, and of all utilities combined.
obj.Level2.AnnualCostOfElectricity = obj.Level2.Electricity_kWh * ...
    obj.HEA.UnitCostOfElectricity;
obj.Level2.UnitCostOfElectricity = obj.HEA.UnitCostOfElectricity;

obj.Level2.AnnualCostOfGas = obj.Level2.Gas_therms * ...
    obj.HEA.UnitCostOfGas;
obj.Level2.UnitCostOfGas = obj.HEA.UnitCostOfGas;

obj.Level2.AnnualCostOfWater = obj.Level2.Water_gallons * ...
    obj.HEA.UnitCostOfWater;
obj.Level2.UnitCostOfWater = obj.HEA.UnitCostOfWater;

obj.Level2.AnnualCostOfOil = obj.Level2.Oil_gallons * ...
    obj.HEA.UnitCostOfOil
obj.Level2.UnitCostOfOil = obj.HEA.UnitCostOfOil; 

obj.Level2.AnnualCostOfPropane = obj.Level2.Propane_gallons * ...
    obj.HEA.UnitCostOfPropane;
obj.Level2.UnitCostOfPropane = obj.HEA.UnitCostOfPropane;

  annualCost = [obj.Level2.AnnualCostOfElectricity  ...
    obj.Level2.AnnualCostOfGas  ...
    obj.Level2.AnnualCostOfWater  ...
    obj.Level2.AnnualCostOfOil  ...
    obj.Level2.AnnualCostOfPropane];
obj.Level2.AnnualCostTotal = sum(annualCost(~isnan(annualCost)));

% CO2 equivalent value in kg/ft2
obj.Level2.CO2e = ...
    (obj.Level2.Electricity_kWh * obj.CarbonEqValueElectricity_kgPerkWh + ...
    obj.Level2.Gas_therms * obj.CarbonEqValueGas_kgPerTherm + ...
    obj.Level2.Oil_gallons * obj.CarbonEqValueOil_kgPerGallon + ...
    obj.Level2.Propane_gallons * obj.CarbonEqValuePropane_kgPerGallon) ...
    / area;

% Water metrics
% Non residential gallons are for irrigation, cooling tower, or "other."
obj.Level2.WaterNonResidential_gallons = ...
    obj.WaterUsageTable.Annual(obj.WaterUsageTable.waterGallons == "Irrigation") + ...
    obj.WaterUsageTable.Annual(obj.WaterUsageTable.waterGallons == "CoolingTower") +...
    obj.WaterUsageTable.Annual(obj.WaterUsageTable.waterGallons == "Other");

% Residential gallons are for dwelling unit water usage.
obj.Level2.WaterResidential_gallons = ...
    obj.WaterUsageTable.Annual(obj.WaterUsageTable.waterGallons == "Totals") - ...
    obj.Level2.WaterNonResidential_gallons;

% Residential water use in gallons per day per bedroom.
obj.Level2.Water_GPDBedroom = obj.Level2.WaterResidential_gallons / 365 / numBRs;

% Space heating energy for each utility in kWh, therms, gallons of oil,
% gallons of propane, and for all utilities combined in kBtu/ft2.
obj.Level2.SpaceHeat_kWh = obj.HeatFuelTable.Electricity_kWh(end);

obj.Level2.SpaceHeatGas_therms = obj.HeatFuelTable.Gas_therms(end);

obj.Level2.SpaceHeatOil_kBtu = obj.HeatFuelTable.HeatingOil_gallons(end);

obj.Level2.SpaceHeatPropane_gallons = obj.HeatFuelTable.Propane_gallons(end);

obj.Level2.SpaceHeat_kBtuFt2 = obj.HeatFuelTable.TotalEnergy_kBtu(end) ...
    / area;

% Space cooling energy in kWh and in kBtu/ft2.
obj.Level2.SpaceCool_kWh = obj.ElectricUsageTable.SpaceCooling(end);

obj.Level2.SpaceCool_kBtuFt2 = obj.Level2.SpaceCool_kWh * 3413 / 1000 / area;

% DHW energy for each utility in kWh, therms, gallons of oil, propane,
% and for all utilities combined in kBtu/ft2.
obj.Level2.DHW_kWh = obj.DHWfuelTable.Annual(obj.DHWfuelTable.DHWfuelType == ...
    "Electricity_kWh");

obj.Level2.DHWGas_therms = obj.DHWfuelTable.Annual(obj.DHWfuelTable.DHWfuelType == ...
    "Gas_therms");

obj.Level2.DHWOil_kBtu = obj.DHWfuelTable.Annual(obj.DHWfuelTable.DHWfuelType == ...
    "HeatingOil_gallons");

obj.Level2.DHWPropane_gallons = obj.DHWfuelTable.Annual(obj.DHWfuelTable.DHWfuelType == ...
    "Propane_gallons");

obj.Level2.DHW_kBtuFt2 = obj.DHWfuelTable.Annual(obj.DHWfuelTable.DHWfuelType == ...
    "TotalEnergy_kBtu") / area;

% Electricity for lights/plug loads/appliances/fans/pumps (no heating, cooling, DHW)
% First, find electricity for space heating/cooling and DHW.
HVAC_kWh = obj.ElectricUsageTable.DHW(end) + ...
    obj.ElectricUsageTable.SpaceHeating(end) + ...
    obj.ElectricUsageTable.SpaceCooling(end);
obj.Level2.NonHVACelec_kBtuFt2 = ...
    (obj.ElectricUsageTable.MonthlyTotals(end) - HVAC_kWh) ...
    * 3413 / 1000 / area;

% Gas or propane use for appliances, kBtu (excludes electricity)
% Need to add propane use to level 2 cooking/drying calculation.
obj.Level2.ApplianceFuel_kBtuFt2 = obj.ApplianceResultsTable.gasUse_therms...
    (obj.ApplianceResultsTable.applianceType == "Totals") * 100 / area;

% runStatsTable = table(runStats, 'VariableNames', {'KeyParameters'}, 'RowNames', ...
%     {'electricity_kWh', 'gas_Therms', 'oil_Gallons', 'propane_Gallons', ...
%     'water_Gallons', 'EUI_kBtu_Ft2', 'cost_Dollars', 'CO2e_kgFt2', 'water_GpdBrRes', ...
%     'water_GallonsNonRes', 'spaceHeat_kWh', 'spaceHeatFuel_kBtu', 'spaceHeat_kBtuFt2', ...
%     'spaceCooling_kBtuFt2', 'DHW_kWh', 'DHWfuel_kBtu', 'DHW_kBtuFt2', 'nonHVACelec_kBtuFt2', ...
%     'applianceFuel_kBtuFt2'});
% 
% obj.RunStatsTable = runStatsTable;


end  % function statement
