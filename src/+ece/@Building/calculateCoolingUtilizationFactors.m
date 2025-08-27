function lossesUtilClg = ...
    calculateCoolingUtilizationFactors(obj, heatLoss12, totalHLC12, ...
    intGainsClgSeason12, solarGainsClgSeason12)
% LOSSESUTILCLG Method for computing the Cooling Utilization factors.
% Utilization factors for the cooling season are applied to thermal losses due
% to conduction, air leakage, and ventilation. I.e. for each month the extent 
% to which building cooling during times of cooler outdoor temperatures offsets
% building heating during times of hotter outdoor temperatures and solar gains.
% This method is drawn from ISO 13790-2006.
% Monthly heating loads in kBtu. heat flow out is positive.
% Monthly cooling loads in kBtu. heat flow out is positive.
% Heat loss coefficient (HLC) for each month in Btu/hr-F.
%  Note: Inputs should be column arrays.

%% Arguments Block
arguments
    % obj: Self-referenced Building object.
    obj (1,1) ece.Building
    % heatLoss12: 12-month column vector of heat loss.
    heatLoss12 (12,1) double
    % totalHLC12: 12-month column vector of total heat losses.
    totalHLC12 (12,1) double
    % intGainsClgSeason12: 12-month column vector of Int. Gains cooling.
    intGainsClgSeason12 (12,1) double
    % solarGainsClgSeason12: 12-month column vector of Solar Gains cooling.
    solarGainsClgSeason12 (12,1) double

end %argblock

%% Compute Cooling Utilization Factors
% Find building heat capacity in Btu/F per square foot of floor area
% from a table of standard values, could be adjusted for unusual constructions.
ThermalCapTbl = ece.Reference.getThermalCapBldgTable(); 
bldgMassBtuF_ft2 = ...
    ThermalCapTbl.ThermalCapacity_Btu_F_Ft2(ThermalCapTbl.Type == obj.ThermalMass);

% Find building thermal capacity in kBtu/F , using the iCFA value for area.
bldgHeatCap = bldgMassBtuF_ft2 * obj.IntConditionedArea_ft2 / 1000;

% constants from ISO 13790, for residential buildings, monthly method.
alphaC0 = 1;
tauC0 = 15;

% Get tau and alpha for cooling for each month. row vectors with 12 elements.
% tau is the time constant for the building in hours. [thermal capacity/HLC] = hours
% alpha is a constant for the calculation based on tau
tauC = bldgHeatCap * 1000 ./ totalHLC12;
alphaC = alphaC0 + tauC / tauC0;

% Find the gains to loss (GLRc) ratio for cooling for each month
% This is the sum of solar and internal gains divided by net heat flow out 
% of the building. If gains to loss ratio is negative for a month, 
% i.e. net heat flow in to building, then utilization factor is 1.0.
% If GLRc is positive, net heat flow out, only a portion of it is counted as
% reducing the cooling required.
% Reverse the sign on the "heat loss" so it works with ISO method.
heatLoss12 = -1 * heatLoss12;
GLRc = (solarGainsClgSeason12 + intGainsClgSeason12) ./ heatLoss12;
GLRc(isinf(GLRc)) = NaN;

% Find the heat loss utilization factors for each month from ISO 13790 formula.
lossesUtilClg = zeros(12,1);
for n = 1:12
    if GLRc(n) < 0
        lossesUtilClg(n) = 1;
    else 
        lossesUtilClg(n) = (1 - GLRc(n)^alphaC(n)) / (1 - GLRc(n)^(alphaC(n)+1));
    end
end

%function end statement
end
