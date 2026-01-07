function computeLevel2(bldg)
%COMPUTELEVEL2 Method to compute a Level2 for a Building object.
%   A Level2 can be calculate from a Building using the mathematics within
%   the calculation methods described by Henry.
%
% 

%% Argument Block
arguments
    % bldg: Building object to compute HEA for.
    bldg (1,1) ece.Building
end %argblock

%% Check Level2 Can Be Done
% There are some data requirements that the Building must meet before it
% can be properly put through Level2 calculation.
% MW_MISU: TODO

%% Compute Intermediary Tables
% Prior to rolling up the Level2 results that are compared to the HEA
% results for calibration/referencing, some tables of results are computed
% from objects inside the Building.

% Calculate Solar Gains
bldg.calculateSolarGains();

% Calculate DHW
bldg.calculateWaterDHW();

% Calculate Appliance Usage
bldg.calculateApplianceElectricAndGasUse();

% Calculate Degree Days
bldg.calculateDegreeDays();

% Calculate Monthly Ventilation
bldg.calculateMonthlyVentilation();

% Calculate Internal Gains and Electricity Use
bldg.calculateInternalGainsAndElec();

% Calculate Space Heating and Cooling
bldg.calculateSpaceHeatingEnergy();
bldg.calculateSpaceCoolingEnergy();

%% Compute Final Level 2 Energy Usage
% From the intermediate tables above, we can now run the energy usage table
% calculation.
bldg.calculateEnergyUsage();

%% Set Flag for Level 2 Results
% This is a SIMPLE flag to indicate, for a Building, that a Level 2
% analysis has been performed.
bldg.HasLevel2Results = true;

end %function

