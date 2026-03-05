function calculateSpaceCoolingEnergy(obj)
% CALCULATESPACECOOLINGENERGY: Method to compute the total Space cooling
% energy for a Building.
% Calculates the total space cooling gainsand required cooling
% input energy of the building. Includes solar and internal gains.
% Gains from conduction through envelope components, as well as the effects
% of ventilation and infiltration.

%% Arguments Block
arguments
    % Obj - Self-referential building object.
    obj (1,1) ece.Building
end %argblock

% determine internal and solar gains that occur during the cooling season
% - kBtu. set up a 12 row vector with fraction for each month.
clgStrtDate = obj.HeatCoolSeasonStartEndDates(3);
clgEndDate = obj.HeatCoolSeasonStartEndDates(4);

% combining cooling degree days cdd1 and cdd2 into 1 single array
% do the same for enthalpy days edd1 and edd2
cdd = reshape([obj.DegreeDaysTable.cdd1, obj.DegreeDaysTable.cdd2]', [], 1);
edd = reshape([obj.DegreeDaysTable.edd1, obj.DegreeDaysTable.edd2]', [], 1);

% eliminate the annual totals
cdd = cdd(1:24);
edd = edd(1:24);

% Extract Start/End Months
startMonth = month(clgStrtDate);
endingMonth = month(clgEndDate);

%Getting the monthly fractions for cooling
clgSeasonMonthFrac12 = zeros(12,1);
clgSeasonMonthFrac12(1:startMonth - 1) = zeros;
clgSeasonMonthFrac12(startMonth) = (31 - day(clgStrtDate))/31;
clgSeasonMonthFrac12(startMonth + 1:endingMonth - 1) = ones;
clgSeasonMonthFrac12(endingMonth) = day(clgStrtDate)/31;
clgSeasonMonthFrac12(endingMonth + 1:12) = zeros;

% Extend the month fraction to the 24 time periods for internal gains
clgSeasonMonthFrac24 = zeros(24, 1);
clgSeasonMonthFrac24(1:2:23,1) = clgSeasonMonthFrac12;
clgSeasonMonthFrac24(2:2:24,1) = clgSeasonMonthFrac12;

% Creating internal gains and solar gains for the cooling season only
% All values are in kBtu.
intGainsClgSeason24 = obj.InternalGainsArray_kBtu(:,2) .* ...
    clgSeasonMonthFrac24;
solarGainsClgSeason12 = obj.TotalSolarGains .* ...
    clgSeasonMonthFrac12;

% Solar gains occur during the day - time period 1. kBtu.
% Future work: add capability for time period 1 not spanning daylight hours.
% Also add estimate of solar gains accruing in time period 2 for light,
% medium and heavy mass buildings.
solarGainsClgSeason24 = zeros(24,1);
solarGainsClgSeason24(1:2:23,1) = solarGainsClgSeason12;

% Getting the  heat loss coefficient (HLC) in BTU/hr-F for conductive loss
% elements like walls, roof, windows, doors, overhangs. The "heat loss"
% coefficient indicates how much heat flows through the assembly for a
% given temperature difference. The direction of heat flow does not
% matter. It is used here to calculate heat gains that create the cooling
% as well as heat losses that to some extent alleviate the cooling load.

% Opaque surface elements.
numOpaque = length(obj.OpaqueSurfaces);
% Glazed surface elements.
numGlazed = length(obj.GlazedSurfaces);
% Slab on grade elements, if any.
numSlab = length(obj.SlabOnGrade);

OpaqueHLC = zeros(1,numOpaque);
GlazedHLC = zeros(1,numGlazed);
SlabHLC = zeros(1,numSlab);

% Looping through each component of each object.
for i=1:numOpaque
    OpaqueHLC(i) = obj.OpaqueSurfaces(i).HeatLossCoeff;
end

for i=1:numGlazed
    GlazedHLC(i) = obj.GlazedSurfaces(i).HeatLossCoeff;
end

%slab heat loss if any. if there is no slab on grade, this is 0.
for i=1:numSlab
    SlabHLC(i) = obj.SlabOnGrade(i).HeatLossCoeff;
end

% Sum the conductive HLC's.
totalCondHLC = sum(OpaqueHLC) + sum(GlazedHLC) + sum(SlabHLC);

% Create a 24 column array with rows for each component for calculations.
% The conductive HLC's are constant over all 24 columns.
OpaqueHLC24 = OpaqueHLC .* ones(24,numOpaque);
GlazedHLC24 = GlazedHLC .* ones(24,numGlazed);
SlabHLC24 = SlabHLC .* ones(24,numSlab);

% Mechanical ventilation and air leakage, and combined value for both.
% The combination of unbalanced ventilation and air leakage is
% sub-additive, modeled as square root of sum of squares, and then balanced
% ventilation is directly added.

% Call the infiltration method in building folder to calculate
% infiltration. Convert air changes per hour to cfm air flow.
% This equation for the combined effect of air leakage and unbalanced
% ventilation, as well as balanced ventilation, is in ASHRAE Fundamentals
% handbook 2021 16.26.
% Infiltration rates in the building object are in the 24 row format.
% Call the calculate infiltration function. 2nd output is cooling ACH.
% The 1st col of building cooling ventilation flows is balanced, the 2nd
% col is unbalanced.
[~, ACHnatClg] = obj.calculateInfiltration();
airLeakageFlow_cfm = ACHnatClg * obj.IntVolume_ft3/60;
comboFlow = sqrt(airLeakageFlow_cfm.^2 + obj.ClngVentilationFlow(:,2).^2) + ...
    obj.ClngVentilationFlow(:,1);
HLCairClg24 = 4.5 * comboFlow;

% Declaring matrices for storing the heat gains for day and night
% components in columns, day and night times for each month in 24 rows of
% above grade conductive parts of heat gain, including slab on grade.
% In addition to these there are 2 more columns:
% 1 col for combined air flow due to mechanical ventilation and air leakage
% 1 col of totals, all in kBtu

% CDD and EDD have been defined so that they are positive for energy flow into
% the building which adds to cooling load, and negative for energy flow out of
% the building which may reduce cooling load, depending on loss utilization.
% (below grade heat loss or gain not considered significant for cooling calculation)
numHeatLosses = numOpaque + numGlazed + numSlab + 2;
heatLoss24 = zeros(24,numHeatLosses);

% Calculate Heat Loss for each component (should this be cooling?)
heatLoss24(:,1:numOpaque) = OpaqueHLC24 .* cdd * 24/1000;
heatLoss24(:,numOpaque+1:numOpaque+numGlazed) = ...
    GlazedHLC24 .* cdd*24/1000;
heatLoss24(:,numOpaque+numGlazed+1:numOpaque+numGlazed+numSlab) = ...
    SlabHLC24 .* cdd*24/1000;
heatLoss24(:,numOpaque+numGlazed+numSlab+1) = ...
    HLCairClg24 .* edd*24/1000;

heatLoss24(:,numHeatLosses) = sum(heatLoss24(:,1:numHeatLosses),2);

% Combine the total building heat gain for day and night, for use with
% utilization factors which are derived for the month as a whole.
% Do the same for internal and solar gains.
% Negative numbers indicate heat flowing out of the building.
heatLoss12 = heatLoss24(1:2:23,numHeatLosses) + ...
    heatLoss24(2:2:24,numHeatLosses);

intGainsClgSeason12 = intGainsClgSeason24(1:2:23) + ...
    intGainsClgSeason24(2:2:24);
solarGainsClgSeason12 = solarGainsClgSeason24(1:2:23) + ...
    solarGainsClgSeason24(2:2:24);

% The total building heat loss coefficient for each month is needed for the
% utilization factors calculaation. Conductive HLC is constant.
% Air movement HLC varies by time period. Average night and day HLCair.
% (In this case the heat loss coefficient is used to calculate heat gains.)
HLCair12 = (HLCairClg24(1:2:23) + HLCairClg24(2:2:24)) / 2;
totalCondHLC12 = totalCondHLC * ones(12,1);
totalHLC12 = totalCondHLC12 + HLCair12;

% call the cooling utilization factors function
lossesUtilClg = obj.calculateCoolingUtilizationFactors(...
    heatLoss12, totalHLC12, ...
    intGainsClgSeason12, solarGainsClgSeason12);

% Replace possible nan values with zero.
lossesUtilClg(isnan(lossesUtilClg)) = 0;

% Monthly loss utilization factors are extended to the 24 time periods,
% assumed equal for day and night.
lossesUtilClg24 = zeros(24, 1);
lossesUtilClg24(1:2:23) = lossesUtilClg;
lossesUtilClg24(2:2:24) = lossesUtilClg;

% Energy balance for the day and night periods of each month.
% Solar gains occur during the day - time period 1.
% Internal gains are assumed relatively constant and divided into time
% periods 1 and 2 by number of hours.

% Net cooling load is solar and internal gains adjusted by conductive and air
% movement heat flow. When conductive and air movement heat flows into the
% building, it is all counted as cooling load. when it flows out of the
% building, the amount that is allowed to decrease cooling load is
% determined by the cooling utilization factors. all in kBtu
heatLoss24Sum = heatLoss24(:,numHeatLosses);
netClgLoad24 = solarGainsClgSeason24 + intGainsClgSeason24 + ...
    heatLoss24Sum .* lossesUtilClg24;

% Time periods with negative net cooling load do not need cooling.
netClgLoad24(netClgLoad24 < 0) = 0;

% Determine the efficiency of each cooling system for each of the 24 time
% periods either as a function of outdoor air temperature, or in some
% cases constant.

% Average outdoor temperature in each of 24 time periods is row 4 of
% WeatherMonthly property of Building.
OAT24 = obj.WeatherMonthly(4,:)';

% Initialize arrays.
numSys = length(obj.HeatCool);
clgInput24 = zeros(24,numSys);
sysCurveAll = zeros(5,numSys);
sysEff24 = zeros(24,numSys);

% Make an array with the coefficients of the efficiency curves for each
% system in rows. 5 columns for the coefficients. Polynomial function of OAT.
% C1*OAT^4 + C2*OAT^3 + C3*OAT^2 + C4*OAT + C5
for sysIdx = 1:numSys
    sysCurveAll(:,sysIdx) = obj.HeatCool(sysIdx).CoolingEfficiencyCurve(:);
end   % for loop

% Calculate the cooling efficiency for each system for each time period.
for sysIdx = 1:numSys
    sysEff24(:,sysIdx) = sysCurveAll(1,sysIdx) .* OAT24.^4 + ...
        sysCurveAll(2,sysIdx) .* OAT24.^3 + ...
        sysCurveAll(3,sysIdx) .* OAT24.^2 + ...
        sysCurveAll(4,sysIdx) .* OAT24 + ...
        sysCurveAll(5,sysIdx);
end   % for loop

% The load on the cooling device includes the distribution losses.
% Multiply the cooling efficiency by the distribution efficiency to get
% overall or total efficiency. Use an array of the distribution efficiencies.
totalEff24 = [obj.HeatCool.DistEffClg] .* sysEff24;

%Find the input energy for each system based on fraction of load served
% and total efficiency. kBtu
for sysIdx = 1:numSys
    clgInput24(:,sysIdx) = (obj.HeatCool(sysIdx).CoolFrac * netClgLoad24) ./ ...
        totalEff24(:,sysIdx);
end   % for loop

% As a check, note the total distribution losses as a fraction of the net
% cooling load. kBtu
distLosses = ([obj.HeatCool.CoolFrac] .* netClgLoad24) .* ...
    (1 - [obj.HeatCool.DistEffHtg]);
distLosses = fillmissing(distLosses, 'constant', 0);
distLossSum = sum(distLosses, 'all');
distLossFrac = distLossSum / sum(netClgLoad24);

% Create Month Column for All Usages
usageTablePeriods = ["January","February","March","April","May","June",...
    "July","August","September","October","November","December",...
    "Annual"];

% The 24 time periods have served their purpose. Results will be reported
% in monthly form. Convert cooling input24 to input12. Add annual and
% monthly totals. kBtu
clgInput12 = zeros(12,numSys);
clgInput12 = clgInput24(1:2:23,:) + clgInput24(2:2:24,:);
clgInput12 = fillmissing(clgInput12, "constant", 0);
clgInput12WiTtls = [clgInput12, sum(clgInput12, 2)];

% Make a table for monthly cooling input for each system with annual
% totals. Show system name, type, and load fraction.
% This is in kBtu.
coolSystemNames = [obj.HeatCool.Name, "MonthlyTotals"]';
coolSystemTypes = [obj.HeatCool.SystemType, "All"]';

loadFracs = fillmissing([obj.HeatCool.CoolFrac], 'constant', 0);
allLoadFractions = [loadFracs, sum(loadFracs)]';

% Compute Annual roll-up of monthly cooling inputs.
annualClgInputs = sum(clgInput12WiTtls,1);
fullCgl12MonthTotals = [clgInput12WiTtls;annualClgInputs];

% MonthTable
monthCoolingTable = array2table(fullCgl12MonthTotals',...
    "VariableNames",usageTablePeriods);

% SystemTable
systemTable = table(...
    coolSystemNames,coolSystemTypes,allLoadFractions,...
    'VariableNames',["Cooling System Name","System Type","Load Fraction"]);

% Space Cooling Table
spaceCoolingTable_kBtu = [systemTable,monthCoolingTable];

% Zero out some rows where the load fractions are zero.
spaceCoolingTable_kBtu(allLoadFractions == 0, :) = [];


% Make a second table with the units in kWh. Add the minor amount of
% electricity used by the controls for the cooling only equipment. Controls
% usage of systems that are both heating and cooling is accounted for under
% heating. Eliminate controls usage for months with zero cooling degree days - daytime.
monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]';

% Get kWh Cooling Values
coolControls_kWh = [obj.HeatCool.ControlskW] .* (24 * monthDays);

% Partition Based on Use
coolControls_kWh = ([obj.HeatCool.SystemFunction] == "CoolingOnly") ...
    .* coolControls_kWh;

coolControls_kWh = (cdd(1:2:23) ~= 0) .* coolControls_kWh;

coolControls_kWh = coolControls_kWh(:,...
    [obj.HeatCool.SystemFunction] == "BothHeatingAndCooling" | ...
    [obj.HeatCool.SystemFunction] == "CoolingOnly");

coolControls_kWh(:, all(coolControls_kWh == 0, 1)) = [];
% Organize the Data
% Add column at end for utility roll-up
coolControls_kWh = [coolControls_kWh, sum(coolControls_kWh,2)];
% Add row to bottom for annual roll-up.
coolControls_kWh = [coolControls_kWh; sum(coolControls_kWh,1)];

% -- Create Kilowatt-Hour Table
% Copy the kBtu table and convert to kBtu.
spaceCoolingTable_kWh = spaceCoolingTable_kBtu;
spaceCoolingTable_kWh{:, 4:16} = ...
    spaceCoolingTable_kWh{:, 4:16} * 1000/3413;

spaceCoolingTable_kWh;
% Add cool Controls kWh (transpose to fit)
spaceCoolingTable_kWh{:, 4:16} = spaceCoolingTable_kWh{:, 4:16} + ...
    coolControls_kWh';

% Write tables to building properties.
obj.SpaceCoolingTable_kBtu = spaceCoolingTable_kBtu;
obj.SpaceCoolingTable_kWh = spaceCoolingTable_kWh;

end % function statement