function calculateEnergyUsage(obj)
% CALCULATEENERGYUSAGE Method to compute the total energy usage for a
% Building; synonymous with evaluating the Level 2 Energy result.
% This function sums up usage of gas, oil, and propane from heating, DHW,
% and any gas using appliances. Other fuels could be added, such as district
% steam, diesel fuel, or wood.
% Add total building electric use as the first line of the outuput table.
% Building electric use hase been summed in the ElectricUsageTable.
%  Note: Each row will represent a month, with the final row being the
%        annual roll-up of all months.

% Instantiate Energy Matrix
energy12 = zeros(13, 5);

% Total building electric usage for 12 months.
energy12(1:12,1) = table2array(obj.ElectricUsageTable(1:12, end));

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

%Updating the tables ElectricUsageTable with space cooling and space
%heating
obj.ElectricUsageTable.("Space Cooling") = obj.SpaceCoolingTable_kWh{end,4:16}';
obj.ElectricUsageTable.("Space Heating") = obj.HeatFuelTable.Electricity_kWh;

%% Create Level 2 KeyResults Object
% Make a table of the key parameters or statistics that are used for
% calibration and for comparing one package to another. Call it runStats.
% All numbers are per year.

%1 electricity_kWh        Total electricity use, kWh
%2 gas_Therms             Total gas use, therms
%3 oil_Gallons            Total oil use, gallons
%4 propane_Gallons        Total propane use, gallons
%5 water_Gallons          Total water use, gallons
%6 EUI_kBtuFt2            Energy use index, kBtu/ft2
%7 cost                   Total cost of all utilities
%8 CO2e_kgFt2             CO2 equivalent emissions, kg / ft2 floor area
%9 water_GpdBrRes         Residential water use, gpd/bedroom (excludes irrigation, cooling tower, etc.)
%10 water_GallonsNonRes   Water use for irrigation, cooling tower, etc., gallons
%11 spaceHeat_kWh         Electricity use for space heat, kWh
%12 spaceHeatFuel_kBtu    Gas, oil, or propane use for space heating, kBtu
%13 spaceHeat_kBtuFt2     EUI for space heating only, kBtu/ft2
%14 spaceCooling_kBtuFt2  EUI for space cooling only, kBtu/ft2
%15 DHW_kWh               Electricity use for domestic hot water, kWh
%16 DHWfuel_kBtu          Gas, oil, or propane use for DHW, kBtu
%17 DHW_kBtuFt2           EUI for DHW only, kBtu/ft2
%18 nonHVAC_kBtuFt2       Electricity for lights/plug loads/appliances/fans/pumps (no heating, cooling, DHW)
%19 applianceFuel_kBtu    Gas or propane use for appliances, kBtu (excludes electricity)

runStats = zeros(19,1);
area = obj.GrossArea_ft2;
numBRs = sum(obj.NumberOfBedroomUnits .* [1, 2, 3, 4]);

runStats(1) = obj.BuildingEnergyUsageTable.Electricity_kWh(end);
runStats(2) = obj.BuildingEnergyUsageTable.Gas_therms(end);
runStats(3) = obj.BuildingEnergyUsageTable.HeatingOil_gallons(end);
runStats(4) = obj.BuildingEnergyUsageTable.Propane_gallons(end);

runStats(5) = obj.WaterUsageTable.Annual(...
    obj.WaterUsageTable.waterGallons == "Totals");

runStats(6) = obj.BuildingEnergyUsageTable.Totals_kBtu(end) / area;

%runStats.CostOfElec = L2Electric_KWH * bldg.HEA.UnitCostofElectricity
%runStats.UnitCostOfElec = bldg.HEA.UnitCostOfElectricity

runStats(7) = runStats(1) * obj.HEA.UnitCostOfElectricity + ...
    runStats(2) * obj.HEA.UnitCostOfGas + ...
    runStats(3) * obj.HEA.UnitCostOfOil + ...
    runStats(4) * obj.HEA.UnitCostOfPropane + ...
    runStats(5) * obj.HEA.UnitCostOfWater;

runStats(8) = (runStats(1) * obj.CarbonEqValueElectricity_kgPerkWh + ...
    runStats(2) * obj.CarbonEqValueGas_kgPerTherm + ...
    runStats(3) * obj.CarbonEqValueOil_kgPerGallon + ...
    runStats(4) * obj.CarbonEqValuePropane_kgPerGallon) ...
    / area;

runStats(10) = obj.WaterUsageTable.Annual(obj.WaterUsageTable.waterGallons == "Irrigation") + ...
    obj.WaterUsageTable.Annual(obj.WaterUsageTable.waterGallons == "CoolingTower") +...
    obj.WaterUsageTable.Annual(obj.WaterUsageTable.waterGallons == "Other");

runStats(9) = (runStats(5) - runStats(10)) / ...
    numBRs / 365;


runStats(11) = obj.HeatFuelTable.Electricity_kWh(end);
runStats(12) = obj.HeatFuelTable.TotalEnergy_kBtu(end) - ...
    (runStats(11) * 3413/1000);
runStats(13) = obj.HeatFuelTable.TotalEnergy_kBtu(end) / area;

runStats(14) = obj.ElectricUsageTable.("Space Cooling")(end) * ...
    (3413/1000 / area);

runStats(15) = obj.DHWfuelTable.Annual(obj.DHWfuelTable.DHWfuelType == ...
    "Electricity_kWh");
runStats(16) = obj.DHWfuelTable.Annual(obj.DHWfuelTable.DHWfuelType == ...
    "TotalEnergy_kBtu") - ((runStats(15) - obj.DHWcontrolsTable.Annual(1)) * 3413/1000);
runStats(17) = obj.DHWfuelTable.Annual(obj.DHWfuelTable.DHWfuelType == ...
    "TotalEnergy_kBtu") / area;

% Compute HVAC/Non-HVAC Sums
HVAC_kWh = obj.ElectricUsageTable.DHW(end) + ...
    obj.ElectricUsageTable.("Space Heating")(end) + ...
    obj.ElectricUsageTable.("Space Cooling")(end);
nonHVAC_kWh = obj.ElectricUsageTable.("Monthly Totals")(end) - ...
    HVAC_kWh;

runStats(18) = (nonHVAC_kWh * 3413/1000) / area;
runStats(19) = obj.ApplianceResultsTable.gasUse_therms...
    (obj.ApplianceResultsTable.applianceType == "Totals") * 100;

% Check. Total kBtu/ft2 should equal the sum of the parts.
% Appliance fuel has to be converted to kBtu/ft2.
check = runStats(6) - sum([runStats(13), runStats(14), runStats(17), ...
    runStats(18), (runStats(19) / area)]);

runStatsTable = table(runStats, 'VariableNames', {'KeyParameters'}, 'RowNames', ...
    {'electricity_kWh', 'gas_Therms', 'oil_Gallons', 'propane_Gallons', ...
    'water_Gallons', 'EUI_kBtu_Ft2', 'cost_Dollars', 'CO2e_kgFt2', 'water_GpdBrRes', ...
    'water_GallonsNonRes', 'spaceHeat_kWh', 'spaceHeatFuel_kBtu', 'spaceHeat_kBtuFt2', ...
    'spaceCooling_kBtuFt2', 'DHW_kWh', 'DHWfuel_kBtu', 'DHW_kBtuFt2', 'nonHVAC_kBtuFt2', ...
    'applianceFuel_kBtu'});

obj.RunStatsTable = runStatsTable;

%% Map RunStats Values to KeyResults Table
% The RunStatsTable will inform the Level2 KeyResults properties in the
% Building. This will be what gets compared to the HEA values.

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

% -- EUI
% EUI by Area
obj.Level2.EUI = runStats(6);

% -- Annual Cost of Utilities
% Get the usage and multiply by the HEA's cost per utility, then roll up
% all for total Annual Cost.
% Electricity
obj.Level2.AnnualCostOfElectricity = obj.Level2.Electricity_kWh * ...
    obj.HEA.UnitCostOfElectricity;
% Gas
obj.Level2.AnnualCostOfGas = obj.Level2.Gas_therms * ...
    obj.HEA.UnitCostOfGas;
% Water
obj.Level2.AnnualCostOfWater = obj.Level2.Water_gallons * ...
    obj.HEA.UnitCostOfWater;
% Oil
obj.Level2.AnnualCostOfOil = obj.Level2.Oil_gallons * ...
    obj.HEA.UnitCostOfOil;
% Propane
obj.Level2.AnnualCostOfPropane = obj.Level2.Propane_gallons * ...
    obj.HEA.UnitCostOfPropane;
% Annual
obj.Level2.AnnualCostTotal = obj.Level2.AnnualCostOfElectricity + ...
    obj.Level2.AnnualCostOfGas + ...
    obj.Level2.AnnualCostOfWater + ...
    obj.Level2.AnnualCostOfOil + ...
    obj.Level2.AnnualCostOfPropane;


% -- Carbon Equivalents
% Get CO2 value
obj.Level2.CO2 = runStats(8);

% -- Water Usages
% Evaluate Residential and Non-Residential Water Uses
obj.Level2.WaterNonResidential_gallons = runStats(10);
obj.Level2.WaterResidential_gallons = runStats(9);

% -- Space Heat/Cool Properties
% Evaluate Space Heat/Cool Values
obj.Level2.SpaceHeat_kWh = obj.HeatFuelTable.Electricity_kWh(end);
obj.Level2.SpaceHeatFuel_therms = runStats(12); % Check
obj.Level2.SpaceHeatOil_gallons = -1;
obj.Level2.SpaceHeatPropane_gallons = -1;
obj.Level2.SpaceHeat_kBtuFt2 = runStats(13);
obj.Level2.SpaceCool_kBtuFt2 = runStats(14);

% -- Domestic Hot Water (DHW) Properties
% Get DHW propreties from above.
obj.Level2.DHW_kWh = runStats(15);
obj.Level2.DHWFuel_kBtu = runStats(16);
obj.Level2.DHWOil_gallons = -1;
obj.Level2.DHWPropane_gallons = -1;
obj.Level2.DHW_kBtuFt2 = runStats(17);

% -- Other Properties
% All other Properties
obj.Level2.NonHVAC_kBtuFt2 = runStats(18);
obj.Level2.ApplianceFuel_kBtu = runStats(19);

% -- Unit Costs of Utilities
% Unit Costs, Based on New Values
obj.Level2.UnitCostOfElectricity = obj.HEA.UnitCostOfElectricity;
obj.Level2.UnitCostOfGas = obj.HEA.UnitCostOfGas;
obj.Level2.UnitCostOfWater = obj.HEA.UnitCostOfWater;
obj.Level2.UnitCostOfOil = obj.HEA.UnitCostOfOil;
obj.Level2.UnitCostOfPropane = obj.HEA.UnitCostOfPropane;

end  % function statement
