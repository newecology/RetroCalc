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

%% Compute Main Utilities.
% Pull in utility usages.
hea.Electricity_kWh = bldg.AnnualElectricUsageTable.kWh(1);
hea.Gas_therms = bldg.AnnualGasUsageTable.Therms(1);
hea.Water_gallons = bldg.AnnualWaterUsageTable.Gallons(1);
hea.Oil_gallons = bldg.AnnualOilUsageTable.Gallons(1);
hea.Propane_gallons = bldg.AnnualPropaneUsageTable.Gallons(1);

%% Compute EUI
% Pull in EUI calculations.
hea.EUI = bldg.AnnualElectricUsageTable.kWh(3);


%% Compute Costs and Total Cost of all Utilities
% Each cost corresponds to a used utility.
hea.AnnualCostOfElectricity = bldg.AnnualElectricUsageTable.Cost(1);
hea.AnnualCostOfGas = bldg.AnnualGasUsageTable.Cost(1);
hea.AnnualCostOfWater = bldg.AnnualWaterUsageTable.Cost(1);
hea.AnnualCostOfOil = bldg.AnnualOilUsageTable.Cost(1);
hea.AnnualCostOfPropane = bldg.AnnualPropaneUsageTable.Cost(1);

% Total Cost
hea.AnnualCostTotal = ...
    hea.AnnualCostOfElectricity + ...
    hea.AnnualCostOfWater + ...
    hea.AnnualCostOfGas + ...
    hea.AnnualCostOfOil + ...
    hea.AnnualCostOfPropane;

%% Compute CO2 Usage
% Convert therms/kWh to equivalent CO2 usage using Mass Rates.
% TODO: These need to be pulled out as inputs that vary with location?
% Or may be set by the user as an input.
elecRate = 0.3991; % for MA (kg*CO2/kWh)
gasRate = 53.06e3; % for MA (kg*CO2/kBtu)
oilRate = 10.19; % kg*CO2/gallons
propaneRate = 5.75; % kg*Co2/gallons

% Get Converted to CO2 Values
kWhInCO2amt = hea.Electricity_kWh * elecRate;
thermsInCO2amt = hea.Gas_therms * gasRate;
gallonsInCO2amt = (hea.Oil_gallons * oilRate) + ...
    (hea.Propane_gallons * propaneRate);

% Compute final CO2 usage per area.
hea.CO2 = (kWhInCO2amt + thermsInCO2amt + gallonsInCO2amt) / bca;

%% Compute Water Usage
% Residential and nonresidential usages.
hea.WaterResidential_gallons = ...
    bldg.AnnualWaterUsageTable.ResidentialGals(1);

hea.WaterNonResidential_gallons = ...
    bldg.AnnualWaterUsageTable.Gallons(1) - ...
    hea.WaterResidential_gallons;


%% Compute SpaceHeat/Cooling
% Get SpaceHeat in therms and kWh, as well as cooling/heating per sqft.
hea.SpaceHeat_kWh = bldg.AnnualElectricUsageTable.Heat(1);
% MW_MISU: Add back SpaceCooling in kWh. (Add back in per Henry)
hea.SpaceHeatFuel_therms = bldg.AnnualGasUsageTable.SpaceHeatTherms(1); 
hea.SpaceHeatOil_gallons = bldg.AnnualOilUsageTable.SpaceHeatGallons(1); 
hea.SpaceHeatPropane_gallons = bldg.AnnualPropaneUsageTable.SpaceHeatGallons(1);

% Convert Values to kBtu
hea.SpaceHeat_kBtuFt2 = ((hea.SpaceHeatFuel_therms * 1e5) + ...
    (bldg.AnnualOilUsageTable.SpaceHeatTherms(1) * 1e5) + ...
    (bldg.AnnualPropaneUsageTable.SpaceHeatTherms(1) * 1e5) + ...
    (hea.SpaceHeat_kWh * 3413)) / 1e3 / bca;

% Space Cooling
hea.SpaceCool_kBtuFt2 = (bldg.AnnualElectricUsageTable.Cool(1) * 3413) / ...
    1e3 / bca;



%% Compute Domestic Hot Water (DHW) Usage
% Compute in kWh, kBtu, and per area.
hea.DHW_kWh = 0; % TODO: This may be computed elsewhere. Checked with NE, 
% will need to make this do something.

% Convert therms to Kbtu
hea.DHWFuel_kBtu = (bldg.AnnualGasUsageTable.DHWTherms(1)) / 1e3; 
% Adding for oil and Propane 
hea.DHWOil_gallons= bldg.AnnualOilUsageTable.DHWGallons(1);
hea.DHWPropane_gallons= bldg.AnnualPropaneUsageTable.DHWGallons(1);

hea.DHW_kBtuFt2 = (hea.DHWFuel_kBtu + ...
    ((hea.DHW_kWh * 3413) / 1e3) + (bldg.AnnualOilUsageTable.DHWTherms(1) * 1e5 / 1e3) + ...
    (bldg.AnnualPropaneUsageTable.DHWTherms(1) * 1e5 / 1e3)) / bca;

%% Compute Other Values
% NonHVAC and Appliance usages in kBtuFt2 and kBtu. Added Propane. 
hea.NonHVAC_kBtuFt2 = ((bldg.AnnualGasUsageTable.StoveDryerTherms(1) * 1e5) + ...
    (bldg.AnnualElectricUsageTable.Base(1) / 3413) + ...
    (bldg.AnnualPropaneUsageTable.StoveDryerTherms(1) *1e5)) / 1e3 / bca;
hea.ApplianceFuel_kBtu = (bldg.AnnualGasUsageTable.StoveDryerTherms(1) + ...
    bldg.AnnualPropaneUsageTable.StoveDryerTherms(1)) * ...
    1e5 / 1e3;

%% Compute Unit Costs
% Unit costs are computed as the ratio of annual utility unit used over the
% annual cost for that utility.
% Electric Unit Cost
hea.UnitCostOfElectricity = ...
    hea.AnnualCostOfElectricity / hea.Electricity_kWh;

% Gas Unit Cost
hea.UnitCostOfGas = ...
    hea.AnnualCostOfGas / hea.Gas_therms;

% Water Unit Cost
hea.UnitCostOfWater = ...
    hea.AnnualCostOfWater / hea.Water_gallons;

% Oil Unit Cost
hea.UnitCostOfOil = ...
    hea.AnnualCostOfOil / hea.Oil_gallons;

% Propane Unit Cost
hea.UnitCostOfPropane = ...
    hea.AnnualCostOfPropane / hea.Propane_gallons;

%% Assign to Building
% Assign HEA object to Building property.
bldg.HEA = hea;

%% Set Flag for HEA Results
% This is a SIMPLE flag to indicate, for a Building, that an HEA
% analysis has been performed.
bldg.HasHEAResults = true;


end %function

