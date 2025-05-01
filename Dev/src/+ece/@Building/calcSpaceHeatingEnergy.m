%Calculates the total space heating losses and required
% heating input energy of the building. Includes solar and internal gains. 
% Losses from conduction through envelope components, as well as due to 
% ventilation, infiltration etc.

function calcSpaceHeatingEnergy(obj)

%% Arguments Block
arguments
    % Obj - Self-referential building object.
    obj (1,1) ece.Building
end %argblock

%%

   %determine internal and solar gains that occur during the heating season
   % in kBtu. Set up a 12 column vector with fraction for each month.
  htgStrtDate = obj.HeatCoolSeasonStartEndDates(1);
  htgEndDate = obj.HeatCoolSeasonStartEndDates(2);

% combining heating degree days hdd1 and hdd2 into 1 single array
  hdd = reshape([obj.DegreeDaysTable.hdd1, obj.DegreeDaysTable.hdd2]', [], 1)';
  hdd = hdd(1:24);

  %Getting the monthly fraction for heating
  htgSeasonMonthFrac12 = zeros(1,12);
  htgSeasonMonthFrac12(1:month(htgEndDate)-1) = ones;
  htgSeasonMonthFrac12(month(htgEndDate)) = day(htgEndDate)/31;
  htgSeasonMonthFrac12(month(htgStrtDate)+1:12) = ones;
  htgSeasonMonthFrac12(month(htgStrtDate)) = (31-day(htgStrtDate))/31;

  % Extend the month fraction to the 24 time periods for internal gains 
  htgSeasonMonthFrac24 = zeros(1, 24);
  htgSeasonMonthFrac24(1:2:23) = htgSeasonMonthFrac12; 
  htgSeasonMonthFrac24(2:2:24) = htgSeasonMonthFrac12;

  % creating internal gains and solar gains for the heating season only
  % All values are in kBtu.
  intGainsHtgSeason24 = obj.InternalGainsArray_kBtu(1,:) .* htgSeasonMonthFrac24;
  solarGainsHtgSeason12 = obj.totalSolarGains .* htgSeasonMonthFrac12;

  % Solar gains occur during the day - time period 1. kBtu.
  % Future add capability for time period 1 not spanning daylight hours.
  % Add estimate of solar gains accruing in time period 2 for light, 
  % medium and heavy mass buildings.
  solarGainsHtgSeason24 = zeros(1,24);
  solarGainsHtgSeason24(1:2:23) = solarGainsHtgSeason12;

  % Calculate heat loss coefficients and heat loss for all building
  % envelope components as well as air leakage and ventilation.

  % Time fractions for periods 1 and 2 to allot below grade losses.
  time1Frac = (obj.HVACStartEndTimePeriod1(2) - obj.HVACStartEndTimePeriod1(1))/24;
  time2Frac = 1 - time1Frac;

  %below grade heat loss, kBtu. 
  BGwallHL = zeros(1,12);
  BGfloorHL = zeros(1,12);
  for n = 1:length(obj.BelowGradeSurfaces)
      BGwallHL = BGwallHL + obj.BelowGradeSurfaces(n).BGwallMonthHeatLoss_kBtu;
      BGfloorHL = BGfloorHL + obj.BelowGradeSurfaces(n).BGfloorMonthHeatLoss_kBtu;
  end % for loop

  % make 24 column arrays for the 24 period calculation
  % monthly loss in time periods 1 & 2 according to time fraction
  BGwallHL24 = zeros(1,24);
  BGfloorHL24 = zeros(1,24);
  BGwallHL24(1:2:23) = BGwallHL * time1Frac;
  BGwallHL24(2:2:24) = BGwallHL * time2Frac;
  BGfloorHL24(1:2:23) = BGfloorHL * time1Frac;
  BGfloorHL24(2:2:24) = BGfloorHL * time2Frac;
  
   % Getting the  heat loss coefficient (HLC) in BTU/hr-F for conductive loss
   % elements like walls, roof, windows, doors, overhangs
   
   % Opaque surface elements.
   numOpaque = length(obj.OpaqueSurfaces);
   % Glazed surface elements. 
   numGlazed = length(obj.GlazedSurfaces);
   % Slab on grade elements, if any.
   numSlab = length(obj.SlabOnGrade);

   OpaqueHLC = zeros(numOpaque,1);
   GlazedHLC = zeros(numGlazed,1);
   SlabHLC = zeros(numSlab,1);

   %looping through each object components
   % create a 24 column array with rows for each component for calculations
   % The HLC is constant over all 24 columns.
   for i = 1:numOpaque
       OpaqueHLC(i) = obj.OpaqueSurfaces(i).HeatLossCoeff;
   end
   
   for i = 1:numGlazed
       GlazedHLC(i) = obj.GlazedSurfaces(i).HeatLossCoeff;
   end 
   
   %slab heat loss if any. if there is no slab on grade, this is 0.
   for i = 1:numSlab
      SlabHLC(i) = obj.SlabOnGrade(i).HeatLossCoeff;
   end
   
   OpaqueHLC = OpaqueHLC .*ones(numOpaque,24);
   GlazedHLC = GlazedHLC .*ones(numGlazed,24);
   SlabHLC = SlabHLC .* ones(numSlab,24);

 % Mechanical ventilation and air leakage, and combined value for both.
 % The combination of unbalanced ventilation and air leakage is 
 % sub-additive, modeled as square root of sum of squares, and then balanced
 % ventilation is directly added. 

 % Call the infiltration method in building folder to calculate
 % infiltration. Convert air changes per hour (ACH) to cfm air flow.
 % This equation for the combined effect of air leakage and unbalanced
 % ventilation, as well as balanced ventilation, is in ASHRAE Fundamentals
 % handbook 2021 16.26.
 % Infiltration ACH rates in the building object are in the 24 column format.
 % Call the calculate infiltration function.  1st output is heating ACH.
 % The 1st row of building heating ventilation flows is balanced, the 2nd
 % row is unbalanced.
 
 [ACHnatHtg, b] = obj.calcInfiltration;
 airLeakageFlow = ACHnatHtg * obj.IntVolume_ft3/60;
 comboFlow = sqrt(airLeakageFlow.^2 + obj.HtngVentilationFlow(2,:).^2) + ...
     obj.HtngVentilationFlow(1,:);
 HLCairHtg = 1.08 * comboFlow;
 
% Declaring matrices for storing the heat losses for day and night
% components in rows, day and night times for each month in 24 columns of
% above grade conductive parts of heat loss, including slab on grade.
% In addition to these there are 4 more rows:
% 1 row for combined air flow due to mech ventilation and natural air
% leakage
% 2 rows for below grade heat loss if any (walls and floor)
% 1 row of totals, all in kBtu
 HLlen = numOpaque + numGlazed + numSlab + 4;
 HeatLoss = zeros(HLlen, 24);
 
 % calculate heat loss for each component in kBtu
 % HLC * HDD * 24 / 1000 = kBtu
 HeatLoss(1:numOpaque,:) = OpaqueHLC .* hdd*24/1000;
 HeatLoss(numOpaque + 1:numOpaque + numGlazed,:) = GlazedHLC .* hdd*24/1000;
 HeatLoss(numOpaque + numGlazed + 1:numOpaque + numGlazed + numSlab, :) = ...
     SlabHLC .* hdd*24/1000;
 HeatLoss(numOpaque + numGlazed + numSlab + 1,:) = HLCairHtg .* hdd*24/1000;
 HeatLoss(numOpaque + numGlazed + numSlab + 2,:) = BGwallHL24;
 HeatLoss(numOpaque+numGlazed + numSlab + 3,:) = BGfloorHL24;
 HeatLoss(HLlen,:) = sum(HeatLoss(1:HLlen,:),1);
 heatLoss24 = HeatLoss(HLlen,:);

 % combining the total building heat loss for day and night, for use with 
 % utilization factors which are derived for the month as a whole
 heatLoss12 = HeatLoss(HLlen,1:2:23) + HeatLoss(HLlen,2:2:24);

 % Also convert internal gains to monthly basis for utilization factors.
 intGainsHtgSeason12 = intGainsHtgSeason24(1:2:23) + intGainsHtgSeason24(2:2:24);

 % Call the calculate heating utilization factors method which is in the
 % buildings folder.
 [intGainsUtilHtg, solarGainsUtilHtg] = obj.calcHtgUtilFactors(heatLoss12, ...
     intGainsHtgSeason12, solarGainsHtgSeason12);

% Energy balance for the day and night periods of each month
% Internal gains utilization factors are assumed equal for day and night.
intGainsUtilHtg24 = zeros(1,24);
intGainsUtilHtg24(1:2:23) = intGainsUtilHtg;
intGainsUtilHtg24(2:2:24) = intGainsUtilHtg;

% Solar gains utilization applies only to time 1 period (daytime).
solarGainsUtilHtg24 = zeros(1,24);
solarGainsUtilHtg24(1:2:23) = solarGainsUtilHtg;

% Heat balance. Net heating load is the base heat loss less solar and 
% internal gains adjusted by utilization factors. kBtu
netHtgLoad24 = heatLoss24 - intGainsUtilHtg24 .* intGainsHtgSeason24 - ...
    solarGainsUtilHtg24 .* solarGainsHtgSeason24;

% A period with net heat gain is considered to not need the heating system
% i.e. lose the negatives if any in swing months.
% This is the heat required for the space. 
netHtgLoad24 = max(netHtgLoad24, 0);

% Determine the efficiency of each heating system for each of the 24 time
% periods either as a function of outdoor air temperature, or in some
% cases constant.

% Average outdoor temperature in each of 24 time periods is row 4 of
% weatherMonthly property of Building.
OAT24 = obj.weatherMonthly(4,:);

% Initialize arrays.
numSys = length(obj.HeatCool);
htgInput24 = zeros(numSys, 24);
sysCurveAll = zeros(numSys, 5);
sysEff24 = zeros(numSys, 24);

% Make an array with the efficiency curves for each system in rows.
% 5 columns for the coefficients. Polynomial function of OAT.
% C1*OAT^4 + C2*OAT^3 + C3*OAT^2 + C4*OAT + C5
for n=1:numSys
    sysCurveAll(n,:) = obj.HeatCool(n).EffCurveHtg(:); 
end   % for loop

% Calculate the heating efficiency for each system for each time period.
for n = 1:numSys
    sysEff24(n,:) = sysCurveAll(n,1) .* OAT24.^4 + ...
        sysCurveAll(n,2) .* OAT24.^3 + ... 
        sysCurveAll(n,3) .* OAT24.^2 + ... 
        sysCurveAll(n,4) .* OAT24 + ... 
        sysCurveAll(n,5);
end   % for loop

% The load placed on the boiler includes the distribution losses. 
% Multiply the heating efficiency by the distribution efficiency to get
% overall or total efficiency. Use an array of the distribution efficiencies.
totalEff24 = [obj.HeatCool.DistEffHtg]' .* sysEff24;

%Find the input energy for each system based on fraction of load served 
% and total efficiency. kBtu
for n = 1:numSys
    htgInput24(n, :) = (obj.HeatCool(n).HeatFrac * netHtgLoad24) ./ ...
        totalEff24(n,:);
end   % for loop

% As a check, note the total distribution losses as a fraction of the 
% net heating load on the spaces. kBtu
% ALTER THIS - USE NET HEATING LOAD
distLosses = ([obj.HeatCool.HeatFrac] * sum(heatLoss24)) .* ...
    (1 - [obj.HeatCool.DistEffHtg]);
distLosses = fillmissing(distLosses, 'constant', 0);
distLossSum = sum(distLosses);
distLossFrac = distLossSum / sum(heatLoss24);

% The 24 time periods have served their purpose. Results will be reported
% in monthly form. Convert heating input24 to input12. Add annual and
% monthly totals.
htgInput12 = zeros(numSys, 12);
htgInput12 = htgInput24(:,1:2:23) + htgInput24(:,2:2:24);
htgInput12 = fillmissing(htgInput12, "constant", 0);
htgInput12MonthTotals = [htgInput12; sum(htgInput12, 1)];

% Make a table for monthly heating input for each system with annual
% totals. Show system name, type, and load fraction.
HeatSystemName = [obj.HeatCool.SystemName, "MonthlyTotals"]';
SystemType = [obj.HeatCool.SystemType, "all"]';
loadFracs = fillmissing([obj.HeatCool.HeatFrac], 'constant', 0);
LoadFraction = [loadFracs, sum(loadFracs)]';
Jan_kBtu = htgInput12MonthTotals(:, 1); Feb = htgInput12MonthTotals(:, 2);
Mar = htgInput12MonthTotals(:, 3); Apr = htgInput12MonthTotals(:, 4); 
May = htgInput12MonthTotals(:, 5); June = htgInput12MonthTotals(:, 6); 
July = htgInput12MonthTotals(:, 7); Aug = htgInput12MonthTotals(:, 8); 
Sep = htgInput12MonthTotals(:, 9); Oct = htgInput12MonthTotals(:, 10); 
Nov = htgInput12MonthTotals(:, 11); Dec = htgInput12MonthTotals(:, 12); 
Annual_kBtu = sum(htgInput12MonthTotals, 2);

SpaceHeatingTable_kBtu = table(HeatSystemName, SystemType, LoadFraction, ...
    Jan_kBtu, Feb, Mar, Apr, May, June, July, ...
    Aug, Sep, Oct, Nov, Dec, Annual_kBtu);
SpaceHeatingTable_kBtu(LoadFraction == 0, :) = [];

% Make a table for monthly energy use by fuel type, gas or electric.
htgInput12Elec = zeros(numSys, 12);
htgInput12Gas = zeros(numSys, 12);
htgInput12HeatingOil = zeros(numSys, 12);
htgInput12Propane = zeros(numSys, 12);
monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

% Convert the monthly input for each energy source into the appropriate units. 
htgInput12Elec = [[obj.HeatCool.EnergySource] == "Electricity"]' ...
    .* htgInput12 * 1000/3413;                          % kWh (3,413 Btu)
htgInput12Gas = [[obj.HeatCool.EnergySource] == "Gas"]' ...
    .* htgInput12 * 1000/100000;                        % therms (100,000 Btu)
htgInput12HeatingOil = [[obj.HeatCool.EnergySource] == "HeatingOil"]' ...
    .* htgInput12 * 1000/138500;                        % gallons (138,500 Btu)
htgInput12Propane = [[obj.HeatCool.EnergySource] == "Propane"]' ...
    .* htgInput12 * 1000/91500;                         % gallons (91,000 Btu)

% Sum the monthly usage for all heating units.
htgInput12ElecAll = sum(htgInput12Elec);
htgInput12GasAll = sum(htgInput12Gas);
htgInput12HeatingOilAll = sum(htgInput12HeatingOil);
htgInput12PropaneAll = sum(htgInput12Propane);

% Compute and add the electricity used by the controls on the systems.
% Fuel systems using gas or oil use a small amount of electricity for
% controls and any small internal pumps. 
% Remove cooling only systems from this. Their controls energy will be
% added in the calc space cooling energy function.
heatControlsElec = [obj.HeatCool.ControlskW]' * 24 * monthDays;
heatControlsElec = [[obj.HeatCool.SystemFunction] ~= "CoolingOnly"]' ...
    .* heatControlsElec;
heatControlsElecAll = sum(heatControlsElec);

% Add the minor electricity use for controls to the electric use (if any)
% of the heating system. 
htgInput12ElecAll = htgInput12ElecAll + heatControlsElecAll;

% Arrange the data so it can be put into a table.
fuelArray = [htgInput12ElecAll; htgInput12GasAll; htgInput12HeatingOilAll; ...
    htgInput12PropaneAll];
fuelArray_kBtu = sum([(fuelArray(1,:) *3413/1000); (fuelArray(2,:) *100); ...
    (fuelArray(3,:) *139000/1000); (fuelArray(4,:) *91000/1000)]);
fuelArray = [fuelArray; fuelArray_kBtu];
fuelArray = [fuelArray, sum(fuelArray, 2)];
Jan = fuelArray(:,1); Feb = fuelArray(:,2); Mar = fuelArray(:,3);
Apr = fuelArray(:,4); May = fuelArray(:,5); Jun = fuelArray(:,6); 
Jul = fuelArray(:,7); Aug = fuelArray(:,8); Sep = fuelArray(:,9);
Oct = fuelArray(:,10); Nov = fuelArray(:,11); Dec = fuelArray(:,12);
AnnualTotals = fuelArray(:,13); 

% Make a table of heating energy usage by fuel type.
HeatingFuelType = ["Electricity_kWh", "Gas_therms", "HeatingOil_gallons", ...
    "Propane_gallons", "TotalEnergy_kBtu"]';

heatFuelTable = table(HeatingFuelType, Jan, Feb, Mar, Apr, May, Jun, Jul, ...
    Aug, Sep, Oct, Nov, Dec, AnnualTotals);

% Write values to building properties.
obj.SpaceHeatingTable_kBtu = SpaceHeatingTable_kBtu;
obj.HeatFuelTable = heatFuelTable;


end  % function end statement