function calcSpaceCoolingEnergy(obj)
     
% Calculates the total space cooling gainsand required cooling
% input energy of the building. Includes solar and internal gains. 
% Gains from conduction through envelope components, as well as the effects
% of ventilation and infiltration.
 
% determine internal and solar gains that occur during the cooling season
% - kBtu. set up a 12 column vector with fraction for each month
  clgStrtDate = obj.HeatCoolSeasonStartEndDates(3);
  clgEndDate = obj.HeatCoolSeasonStartEndDates(4);

  % combining cooling degree days cdd1 and cdd2 into 1 single array
  % do the same for enthalpy days edd1 and edd2
  cdd = reshape([obj.DegreeDaysTable.cdd1, obj.DegreeDaysTable.cdd2]', [], 1)';
  edd = reshape([obj.DegreeDaysTable.edd1, obj.DegreeDaysTable.edd2]', [], 1)';
  % eliminate the annual totals
  cdd = cdd(1:24);
  edd = edd(1:24);

  %Getting the monthly fractions for cooling
  clgSeasonMonthFrac12 = zeros(1,12);
  clgSeasonMonthFrac12(1:month(clgStrtDate) - 1) = zeros;
  clgSeasonMonthFrac12(month(clgStrtDate)) = (31 - day(clgStrtDate))/31;
  clgSeasonMonthFrac12(month(clgStrtDate) + 1:month(clgEndDate) - 1) = ones;
  clgSeasonMonthFrac12(month(clgEndDate)) = day(clgStrtDate)/31;
  clgSeasonMonthFrac12(month(clgEndDate) + 1:12) = zeros;

  % Extend the month fraction to the 24 time periods for internal gains 
  clgSeasonMonthFrac24 = zeros(1, 24);
  clgSeasonMonthFrac24(1:2:23) = clgSeasonMonthFrac12; 
  clgSeasonMonthFrac24(2:2:24) = clgSeasonMonthFrac12;
  
  % Creating internal gains and solar gains for the cooling season only
  % All values are in kBtu.
  intGainsClgSeason24 = obj.InternalGainsArray_kBtu(2,:) .* clgSeasonMonthFrac24;
  solarGainsClgSeason12 = obj.totalSolarGains .* clgSeasonMonthFrac12;

  % Solar gains occur during the day - time period 1. kBtu.
  % Future work: add capability for time period 1 not spanning daylight hours.
  % Also add estimate of solar gains accruing in time period 2 for light, 
  % medium and heavy mass buildings.
  solarGainsClgSeason24 = zeros(1,24);
  solarGainsClgSeason24(1:2:23) = solarGainsClgSeason12;

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

   OpaqueHLC = zeros(numOpaque,1);
   GlazedHLC = zeros(numGlazed,1);
   SlabHLC = zeros(numSlab,1);

   % Looping through each component of each object. 
   for i=1:numOpaque
       OpaqueHLC(i) = obj.OpaqueSurfaces(i).HeatLossCoeff;
   end
  
   for i=1:numGlazed
       GlazedHLC(i) = obj.GlazedSurfaces(i).HeatLossCoeff;
   end 
   
   %slab heat loss if any. if there is no slab on grade, this is 0.
   SlabHLC=zeros(numSlab,1);
   for i=1:numSlab
      SlabHLC(i) = obj.SlabOnGrade(i).HeatLossCoeff;
   end
 
   % Sum the conductive HLC's.
   totalCondHLC = sum(OpaqueHLC) + sum(GlazedHLC) + sum(SlabHLC);

   % Create a 24 column array with rows for each component for calculations.
   % The conductive HLC's are constant over all 24 columns.
   OpaqueHLC24 = OpaqueHLC .* ones(numOpaque,24);
   GlazedHLC24 = GlazedHLC .* ones(numGlazed,24);
   SlabHLC24 = SlabHLC .* ones(numSlab,24);

 % Mechanical ventilation and air leakage, and combined value for both.
 % The combination of unbalanced ventilation and air leakage is 
 % sub-additive, modeled as square root of sum of squares, and then balanced
 % ventilation is directly added.

 % Call the infiltration method in building folder to calculate
 % infiltration. Convert air changes per hour to cfm air flow.
 % This equation for the combined effect of air leakage and unbalanced
 % ventilation, as well as balanced ventilation, is in ASHRAE Fundamentals
 % handbook 2021 16.26.
 % Infiltration rates in the building object are in the 24 column format.
 % Call the calculate infiltration function. 2nd output is cooling ACH.
 % The 1st row of building cooling ventilation flows is balanced, the 2nd
 % row is unbalanced.
 [b, ACHnatClg] = obj.calcInfiltration;
 airLeakageFlow_cfm = ACHnatClg * obj.IntVolume_ft3/60;
 comboFlow = sqrt(airLeakageFlow_cfm.^2 + obj.ClngVentilationFlow(2,:).^2) + ...
     obj.ClngVentilationFlow(1,:);
 HLCairClg24 = 4.5 * comboFlow;
 
% Declaring matrices for storing the heat gains for day and night
% components in rows, day and night times for each month in 24 columns of
% above grade conductive parts of heat gain, including slab on grade.
% In addition to these there are 2 more rows:
% 1 row for combined air flow due to mechanical ventilation and air leakage
% 1 row of totals, all in kBtu

% CDD and EDD have been defined so that they are positive for energy flow into
% the building which adds to cooling load, and negative for energy flow out of
% the building which may reduce cooling load, depending on loss utilization.
% (below grade heat loss or gain not considered significant for cooling calculation)

 HLlen = numOpaque + numGlazed + numSlab + 2;
 heatLoss24 = zeros(HLlen, 24);
 heatLoss24(1:numOpaque,:) = OpaqueHLC24 .* cdd*24/1000;
 heatLoss24(numOpaque+1:numOpaque+numGlazed,:) = GlazedHLC24 .* cdd*24/1000;
 heatLoss24(numOpaque+numGlazed+1:numOpaque+numGlazed+numSlab,:) = SlabHLC24 .* cdd*24/1000;
 heatLoss24(numOpaque+numGlazed+numSlab+1,:) = HLCairClg24 .* edd*24/1000;
 heatLoss24(HLlen,:) = sum(heatLoss24(1:HLlen,:),1);

 % Combine the total building heat gain for day and night, for use with 
 % utilization factors which are derived for the month as a whole.
 % Do the same for internal and solar gains.
 % Negative numbers indicate heat flowing out of the building.
 heatLoss12 = heatLoss24(HLlen,1:2:23) + heatLoss24(HLlen,2:2:24);
 intGainsClgSeason12 = intGainsClgSeason24(1:2:23) +  intGainsClgSeason24(2:2:24);
 solarGainsClgSeason12 = solarGainsClgSeason24(1:2:23) + solarGainsClgSeason24(2:2:24);

 % The total building heat loss coefficient for each month is needed for the 
 % utilization factors calculaation. Conductive HLC is constant. 
 % Air movement HLC varies by time period. Average night and day HLCair.
 % (In this case the heat loss coefficient is used to calculate heat gains.)
 HLCair12 = (HLCairClg24(1:2:23) + HLCairClg24(2:2:24)) / 2;
 totalCondHLC12 = totalCondHLC * ones(1,12);
 totalHLC12 = totalCondHLC12 + HLCair12;

 % call the cooling utilization factors function
 lossesUtilClg = zeros(1,12);
 lossesUtilClg = obj.calcClngUtilFactors(heatLoss12, totalHLC12, ...
     intGainsClgSeason12, solarGainsClgSeason12);

% Replace possible nan values with zero.
lossesUtilClg(isnan(lossesUtilClg)) = 0;

% Monthly loss utilization factors are extended to the 24 time periods,
% assumed equal for day and night.
lossesUtilClg24 = zeros(1, 24);
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
heatLoss24Sum = heatLoss24(HLlen,:);
netClgLoad24 = solarGainsClgSeason24 + intGainsClgSeason24 + ...
    heatLoss24Sum .* lossesUtilClg24; 

% Time periods with negative net cooling load do not need cooling.
netClgLoad24(netClgLoad24<0) = 0; 

% Determine the efficiency of each cooling system for each of the 24 time
% periods either as a function of outdoor air temperature, or in some
% cases constant.

% Average outdoor temperature in each of 24 time periods is row 4 of
% weatherMonthly property of Building.
OAT24 = obj.weatherMonthly(4,:);

% Initialize arrays.
numSys = length(obj.HeatCool);
clgInput24 = zeros(numSys, 24);
sysCurveAll = zeros(numSys, 5);
sysEff24 = zeros(numSys, 24);

% Make an array with the coefficients of the efficiency curves for each 
% system in rows. 5 columns for the coefficients. Polynomial function of OAT.
% C1*OAT^4 + C2*OAT^3 + C3*OAT^2 + C4*OAT + C5
for n=1:numSys
    sysCurveAll(n,:) = obj.HeatCool(n).EffCurveClg(:); 
end   % for loop

% Calculate the cooling efficiency for each system for each time period.
for n = 1:numSys
    sysEff24(n,:) = sysCurveAll(n,1) .* OAT24.^4 + ...
        sysCurveAll(n,2) .* OAT24.^3 + ... 
        sysCurveAll(n,3) .* OAT24.^2 + ... 
        sysCurveAll(n,4) .* OAT24 + ... 
        sysCurveAll(n,5);
end   % for loop

% The load on the cooling device includes the distribution losses. 
% Multiply the cooling efficiency by the distribution efficiency to get
% overall or total efficiency. Use an array of the distribution efficiencies.
totalEff24 = [obj.HeatCool.DistEffClg]' .* sysEff24;

%Find the input energy for each system based on fraction of load served 
% and total efficiency. kBtu
for n = 1:numSys
    clgInput24(n, :) = (obj.HeatCool(n).CoolFrac * netClgLoad24) ./ ...
        totalEff24(n,:);
end   % for loop

% As a check, note the total distribution losses as a fraction of the net 
% cooling load. kBtu
distLosses = ([obj.HeatCool.CoolFrac]' * netClgLoad24) .* ...
    (1 - [obj.HeatCool.DistEffHtg]');
distLosses = fillmissing(distLosses, 'constant', 0);
distLossSum = sum(distLosses, 'all');
distLossFrac = distLossSum / sum(netClgLoad24);

% The 24 time periods have served their purpose. Results will be reported
% in monthly form. Convert cooling input24 to input12. Add annual and
% monthly totals. kBtu
clgInput12 = zeros(numSys, 12);
clgInput12 = clgInput24(:,1:2:23) + clgInput24(:,2:2:24);
clgInput12 = fillmissing(clgInput12, "constant", 0);
clgInput12WiTtls = [clgInput12; sum(clgInput12, 1)];

% Make a table for monthly cooling input for each system with annual
% totals. Show system name, type, and load fraction.
% This is in kBtu.
CoolSystemName = [obj.HeatCool.SystemName, "MonthlyTotals"]';
SystemType = [obj.HeatCool.SystemType, "all"]';
loadFracs = fillmissing([obj.HeatCool.CoolFrac], 'constant', 0);
LoadFraction = [loadFracs, sum(loadFracs)]';
Jan_kBtu = clgInput12WiTtls(:, 1); Feb = clgInput12WiTtls(:, 2);
Mar = clgInput12WiTtls(:, 3); Apr = clgInput12WiTtls(:, 4); 
May = clgInput12WiTtls(:, 5); June = clgInput12WiTtls(:, 6); 
July = clgInput12WiTtls(:, 7); Aug = clgInput12WiTtls(:, 8); 
Sep = clgInput12WiTtls(:, 9); Oct = clgInput12WiTtls(:, 10); 
Nov = clgInput12WiTtls(:, 11); Dec = clgInput12WiTtls(:, 12); 
Annual_kBtu = sum(clgInput12WiTtls, 2);

SpaceCoolingTable_kBtu = table(CoolSystemName, SystemType, LoadFraction, ...
    Jan_kBtu, Feb, Mar, Apr, May, June, July, ...
    Aug, Sep, Oct, Nov, Dec, Annual_kBtu);
SpaceCoolingTable_kBtu(LoadFraction == 0, :) = [];

% Make a second table with the units in kWh. Add the minor amount of
% electricity used by the controls for the cooling only equipment. Controls
% usage of systems that are both heating and cooling is accounted for under
% heating. Eliminate controls usage for months with zero cooling degree days - daytime.
monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
coolControls_kWh = [obj.HeatCool.ControlskW]' * 24 * monthDays;
coolControls_kWh = [[obj.HeatCool.SystemFunction] == "CoolingOnly"]' ...
    .* coolControls_kWh;
coolControls_kWh = [cdd(1:2:23) ~= 0] .* coolControls_kWh;
coolControls_kWh = coolControls_kWh([obj.HeatCool.SystemFunction] == ...
    "BothHeatingAndCooling" | [obj.HeatCool.SystemFunction] == "CoolingOnly", :); 
coolControls_kWh = [coolControls_kWh; sum(coolControls_kWh)];
coolControls_kWh = [coolControls_kWh, sum(coolControls_kWh, 2)];

% Use the table in kBtu and convert to kWh. Add the controls kWh.
SpaceCoolingTable_kWh = SpaceCoolingTable_kBtu;
SpaceCoolingTable_kWh{:, 4:16} = SpaceCoolingTable_kWh{:, 4:16} *  1000/3413;
SpaceCoolingTable_kWh{:, 4:16} = SpaceCoolingTable_kWh{:, 4:16} + ...
    coolControls_kWh;

SpaceCoolingTable_kWh = renamevars(SpaceCoolingTable_kWh, "Jan_kBtu", ...
    "Jan_kWh");
SpaceCoolingTable_kWh = renamevars(SpaceCoolingTable_kWh, "Annual_kBtu", ...
    "Annual_kWh");

% Write tables to building properties.
obj.SpaceCoolingTable_kBtu = SpaceCoolingTable_kBtu;
obj.SpaceCoolingTable_kWh = SpaceCoolingTable_kWh;

end % function statement