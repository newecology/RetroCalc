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
% Default initialization of HEA.
hea = ece.HEA;

%% Extract Shared Values
% Get Building Conditioned area
bca = bldg.BldgArea_ft2(2);

%% Compute Main Utilities.
% Pull in utility usages.
hea.Electricity_kWh = bldg.AnnualElectricUsageTable.kWh(1);
hea.Gas_therms = bldg.AnnualGasUsageTable.Therms(1);
hea.Water_gallons = bldg.AnnualWaterUsageTable.Gallons(1);


%% Compute EUI
% Pull in EUI calculations.
hea.EUI = bldg.AnnualElectricUsageTable.kWh(3);


%% Compute Costs and Total Cost of all Utilities
% Each cost corresponds to a used utility.
hea.CostElectricity = bldg.AnnualElectricUsageTable.Cost(1);
hea.CostGas = bldg.AnnualGasUsageTable.Cost(1);
hea.CostWater = bldg.AnnualWaterUsageTable.Cost(1);

% Total Cost
hea.CostTotal = hea.CostElectricity + hea.CostWater + hea.CostGas;

%% Compute CO2 Usage
% Convert therms/kWh to equivalent CO2 usage using Mass Rates.
% TODO: These need to be pulled out as inputs that vary with location.
elecRate = 0.3991; % for MA (kg*CO2/kWh)
gasRate = 53.06e3; % for MA (kg*CO2/kBtu)

% Get Converted to CO2 Values
kWhToCO2amt = hea.Electricity_kWh * elecRate;
thermsToCO2amt = hea.Gas_therms * gasRate;

% Compute final CO2 usage per area.
hea.CO2 = (kWhToCO2amt + thermsToCO2amt) / bca;

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
hea.SpaceHeatFuel_therms = bldg.AnnualGasUsageTable.SpaceHeatTherms(1);

% Convert Values to kBtu
hea.SpaceHeat_kBtuFt2 = ((hea.SpaceHeatFuel_therms * 1e5) + ...
    (hea.SpaceHeat_kWh * 3413)) / 1e3 / bca;
hea.SpaceCool_kBtuFt2 = (hea.SpaceHeat_kWh * 3413) / 1e3 / bca;


%% Compute Domestic Hot Water (DHW) Usage
% Compute in kWh, kBtu, and per area.
hea.DHW_kWh = 0; % TODO: This may be computed elsewhere. Checked with NE, 
% will need to make this do something.

% Convert therms to Kbtu
hea.DHWFuel_kBtu = (bldg.AnnualGasUsageTable.DHWTherms(1) * 1e5) / 1e3;
hea.DHW_kBtuFt2 = (hea.DHWFuel_kBtu + ...
    ((hea.DHW_kWh * 3413) / 1e3)) / bca;

%% Compute Other Values
% NonHVAC and Applicate usages in kBtuFt2 and kBtu.
hea.NonHVAC_kBtuFt2 = ((bldg.AnnualGasUsageTable.StoveDryerTherms(1) * 1e5) + ...
    (bldg.AnnualElectricUsageTable.Base(1) / 3413)) / 1e3 / bca;
hea.ApplianceFuel_kBtu = bldg.AnnualGasUsageTable.StoveDryerTherms(1) * ...
    1e5 / 1e3;

%% Assign to Building
% Assign HEA object to Building property.
bldg.HEA = hea;


end %function

