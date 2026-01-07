function computeHEA(bldg)
%COMPUTEHEA Method to compute an HEA for a Building object.
%   An HEA can be calculate from a Building extremely easily by leverage
%   precomputed AnnualUtilityTables and and MonthlyProfile for its compnent
%   utilities.

%% Argument Block
arguments
    % bldg: Building object to compute HEA for.
    bldg (1,1) ece.Building
end %argblock

%% Create Instance of HEA
% Default initialization of HEA KeyResults object.
hea = ece.KeyResults;

%% Confirm Building Can Undergo HEA
% To trap any errors, ensure that the Building actually has the requisite
% properties to undergo an HEA. This is provided by the flag in the
% building that checks that all the necessary utility tables exist. If the
% Building is not eligible, we will return a column of NaNs.
if (~bldg.CanUndergoHEA)
    % Set default key results and return.
    bldg.HEA = hea;
    warning(bldg.Name + " unable to undergo HEA.");
    return;
end %endif


%% Extract Shared Values
% Get Building Conditioned area
bca = bldg.GrossConditionedArea_ft2;

% Get building number of bedrooms
numBRs = sum(bldg.NumberOfBedroomUnits .* [1, 2, 3, 4]);

%% Compute Main Utilities.
% Pull in total utility usages for the building.
hea.Electricity_kWh = bldg.AnnualElectricUsageTable.TotalkWh(1);
hea.Gas_therms = bldg.AnnualGasUsageTable.TotalTherms(1);
hea.Water_gallons = bldg.AnnualWaterUsageTable.Gallons(1);
hea.Oil_gallons = bldg.AnnualOilUsageTable.TotalGallons(1);
hea.Propane_gallons = bldg.AnnualPropaneUsageTable.TotalGallons(1);

%% Compute EUI
% Pull in EUI calculations for electricity and fossil fuels (gas, oil, 
% and propane). Energy Use Index in kBtu/ft2.
hea.EUI = bldg.AnnualElectricUsageTable.TotalkWh(3) + ...
    bldg.AnnualGasUsageTable.TotalTherms(3) + ...
    bldg.AnnualOilUsageTable.TotalGallons(3) + ...
    bldg.AnnualPropaneUsageTable.TotalGallons(3);

%% Compute Annual Costs of all Utilities
% Each cost corresponds to a utility. If a building does not have
% a particular utility type (eg. oil), that item is zero. 
hea.AnnualCostOfElectricity = bldg.AnnualElectricUsageTable.Cost(1);
hea.AnnualCostOfGas = bldg.AnnualGasUsageTable.Cost(1);
hea.AnnualCostOfWater = bldg.AnnualWaterUsageTable.Cost(1);
hea.AnnualCostOfOil = bldg.AnnualOilUsageTable.Cost(1);
hea.AnnualCostOfPropane = bldg.AnnualPropaneUsageTable.Cost(1);

% Total combined cost
hea.AnnualCostTotal = ...
    hea.AnnualCostOfElectricity + ...
    hea.AnnualCostOfWater + ...
    hea.AnnualCostOfGas + ...
    hea.AnnualCostOfOil + ...
    hea.AnnualCostOfPropane;

%% Compute CO2e Usage
% Convert therms/gallons/kWh to equivalent CO2 usage using Mass Rates
% or regional rates. Values are from the EPA.
elecRate = bldg.CarbonEqValueElectricity_kgPerkWh; 
gasRate = bldg.CarbonEqValueGas_kgPerTherm; 
oilRate = bldg.CarbonEqValueOil_kgPerGallon; 
propaneRate = bldg.CarbonEqValuePropane_kgPerGallon; 

% Find CO2e values in kg.
CO2eElectricity = hea.Electricity_kWh * elecRate;
CO2eGas = hea.Gas_therms * gasRate;
CO2eOil = hea.Oil_gallons * oilRate;
CO2ePropane = hea.Propane_gallons * propaneRate;

% Compute final CO2 usage per area. kg/ft2 per year.
hea.CO2e = (CO2eElectricity + CO2eGas + CO2eOil + CO2ePropane) / bca;

%% Compute Water Usage
% Residential and nonresidential usages.
hea.WaterResidential_gallons = ...
    bldg.AnnualWaterUsageTable.ResidentialGals(1);

hea.WaterNonResidential_gallons = ...
    bldg.AnnualWaterUsageTable.AdjGallons(1) - ...
    bldg.AnnualWaterUsageTable.ResidentialGals(1);

hea.Water_GPDBedroom = hea.WaterResidential_gallons / 365 / numBRs;

%% Compute SpaceHeat/Cooling
% Get space heating usage for electricity and fossil fuels in energy units
% (kWh, therms, gallons) as well as cooling/heating in kBtu per sqft.
hea.SpaceHeat_kWh = bldg.AnnualElectricUsageTable.Heat(1);
hea.SpaceHeatGas_therms = bldg.AnnualGasUsageTable.SpaceHeatTherms(1); 
hea.SpaceHeatOil_kBtu = bldg.AnnualOilUsageTable.SpaceHeatkBtu(1); 
hea.SpaceHeatPropane_gallons = bldg.AnnualPropaneUsageTable.SpaceHeatGallons(1);

% Convert Values to kBtu per ft2.
hea.SpaceHeat_kBtuFt2 = ((hea.SpaceHeatGas_therms * 1e5) + ...
    (bldg.AnnualOilUsageTable.SpaceHeatkBtu(1) * 1e3) + ...
    (bldg.AnnualPropaneUsageTable.SpaceHeatGallons(1) * 91500) + ...
    (hea.SpaceHeat_kWh * 3413)) / 1e3 / bca;

% Space Cooling
hea.SpaceCool_kWh = bldg.AnnualElectricUsageTable.Cool(1);
hea.SpaceCool_kBtuFt2 = hea.SpaceCool_kWh * 3413 / ...
    1e3 / bca;

%% Compute Domestic Hot Water (DHW) Usage
% Compute in kWh, kBtu, and per area.
hea.DHW_kWh = bldg.AnnualElectricUsageTable.DHW(1); 
hea.DHWGas_therms = bldg.AnnualGasUsageTable.DHWTherms(1); 
hea.DHWOil_kBtu = bldg.AnnualOilUsageTable.DHWkBtu(1);
hea.DHWPropane_gallons = bldg.AnnualPropaneUsageTable.DHWGallons(1);

% Convert physical units to kBtu
hea.DHW_kBtuFt2 = ((hea.DHW_kWh * 3413) + (hea.DHWGas_therms * 1e5) + ...
    (hea.DHWOil_kBtu * 1e3) + ...
    (hea.DHWPropane_gallons * 91500)) / 1e3/ bca;

%% Compute Other Values
% NonHVAC electricity usage in kBtu per ft2.
% Electricity that is not used for heating or cooling. It is used
% for lights, plug loads, appliances, fans, and pumps.
hea.NonHVACelec_kBtuFt2 = bldg.AnnualElectricUsageTable.Base(1) * 3413 ...
    / 1e3 / bca;
% Appliance fuel usage in kBtu per ft2.
% Includes natural gas and propane used for cooking and clothes drying.
% Does not include heating of domestic hot water.
hea.ApplianceFuel_kBtuFt2 = ((bldg.AnnualGasUsageTable.StoveDryerTherms(1) * 1e5) + ...
    (bldg.AnnualPropaneUsageTable.StoveDryerGallons(1) * 91500)) ...
    / 1e3 / bca;

%% Compute Unit Costs
% Unit costs are computed as the ratio of annual utility unit used over the
% annual cost for that utility for the most recent year.
% Electric Unit Cost. $/kWh
hea.UnitCostOfElectricity = bldg.AnnualElectricUsageTable.Cost(end) / ...
    bldg.AnnualElectricUsageTable.TotalkWh(end);
    
% Gas Unit Cost. $/therm
hea.UnitCostOfGas = bldg.AnnualGasUsageTable.Cost(end) / ...
    bldg.AnnualGasUsageTable.TotalTherms(end);

% Water Unit Cost. $/gallon
hea.UnitCostOfWater = bldg.AnnualWaterUsageTable.Cost(end) / ...
    bldg.AnnualWaterUsageTable.Gallons(end);

% Oil Unit Cost $/gallon
hea.UnitCostOfOil = bldg.AnnualOilUsageTable.Cost(end) / ...
    bldg.AnnualOilUsageTable.TotalGallons(end);

% Propane Unit Cost $/gallon
hea.UnitCostOfPropane = bldg.AnnualPropaneUsageTable.Cost(end) / ...
    bldg.AnnualPropaneUsageTable.TotalGallons(end);

% Alternate method based on the row 1 average usage and cost.
% Electric Unit Cost
% hea.UnitCostOfElectricity = ...
%     hea.AnnualCostOfElectricity / hea.Electricity_kWh;

% Gas Unit Cost
% hea.UnitCostOfGas = ...
%     hea.AnnualCostOfGas / hea.Gas_therms;

% Water Unit Cost
% hea.UnitCostOfWater = ...
%     hea.AnnualCostOfWater / hea.Water_gallons;

% Oil Unit Cost
% hea.UnitCostOfOil = ...
%     hea.AnnualCostOfOil / hea.Oil_gallons;

% Propane Unit Cost
% hea.UnitCostOfPropane = ...
%     hea.AnnualCostOfPropane / hea.Propane_gallons;

%% Assign to Building
% Assign HEA object to Building property.
bldg.HEA = hea;

%% Set Flag for HEA Results
% This is a SIMPLE flag to indicate, for a Building, that an HEA
% analysis has been performed.
bldg.HasHEAResults = true;


end %function

