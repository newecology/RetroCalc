function calculateSpaceHeatingEnergy(obj)
%Calculates the total space heating losses and required
% heating input energy of the building. Includes solar and internal gains.
% Losses from conduction through envelope components, as well as due to
% ventilation, infiltration etc. Units in kBtu.

%% Arguments Block
arguments
    % Obj - Self-referential building object.
    obj (1,1) ece.Building
end %argblock

%determine internal and solar gains that occur during the heating season
% in kBtu. Set up a 12 column vector with fraction for each month.
htgStrtDate = obj.HeatCoolSeasonStartEndDates(1);
htgEndDate = obj.HeatCoolSeasonStartEndDates(2);

% combining heating degree days hdd1 and hdd2 into 1 single array
hdd = reshape([obj.DegreeDaysTable.hdd1, obj.DegreeDaysTable.hdd2]',[],1);
hdd = hdd(1:24);

% Extract Start/End Months
startMonth = month(htgStrtDate);
endingMonth = month(htgEndDate);

%Getting the monthly fraction for heating
htgSeasonMonthFrac12 = zeros(12,1);
htgSeasonMonthFrac12(1:(endingMonth-1)) = ones;
htgSeasonMonthFrac12(endingMonth) = day(htgEndDate)/31;
htgSeasonMonthFrac12((startMonth+1):12) = ones;
htgSeasonMonthFrac12(startMonth) = (31-day(htgStrtDate))/31;

% Extend the month fraction to the 24 time periods for internal gains
htgSeasonMonthFrac24 = zeros(24, 1);
htgSeasonMonthFrac24(1:2:23,1) = htgSeasonMonthFrac12;
htgSeasonMonthFrac24(2:2:24,1) = htgSeasonMonthFrac12;

% creating internal gains and solar gains for the heating season only
% All values are in kBtu.
intGainsHtgSeason24 = obj.InternalGainsArray_kBtu(:,1) .* ...
    htgSeasonMonthFrac24;
solarGainsHtgSeason12 = obj.TotalSolarGains .* ...
    htgSeasonMonthFrac12;

% Solar gains occur during the day - time period 1. kBtu.
% Future add capability for time period 1 not spanning daylight hours.
% Add estimate of solar gains accruing in time period 2 for light,
% medium and heavy mass buildings.
solarGainsHtgSeason24 = zeros(24,1);
solarGainsHtgSeason24(1:2:23,1) = solarGainsHtgSeason12;

% Calculate heat loss coefficients and heat loss for all building
% envelope components as well as air leakage and ventilation.

% Time fractions for periods 1 and 2 to allot below grade losses.
time1Frac = (obj.HVACStartEndTimePeriod1(2) - obj.HVACStartEndTimePeriod1(1))/24;
time2Frac = 1 - time1Frac;

%below grade heat loss, kBtu.
BGwallHL = zeros(12,1);
BGfloorHL = zeros(12,1);
for sysIdx = 1:length(obj.BelowGradeSurfaces)
    BGwallHL = BGwallHL + obj.BelowGradeSurfaces(sysIdx).BGwallMonthHeatLoss_kBtu;
    BGfloorHL = BGfloorHL + obj.BelowGradeSurfaces(sysIdx).BGfloorMonthHeatLoss_kBtu;
end % for loop

% make 24 row, 1 col arrays for the 24 period calculation
% monthly loss in time periods 1 & 2 according to time fraction
BGwallHL24 = zeros(24,1);
BGfloorHL24 = zeros(24,1);
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

OpaqueHLC = zeros(1,numOpaque);
GlazedHLC = zeros(1,numGlazed);
SlabHLC = zeros(1,numSlab);

%looping through each object components
% create a 24 row array with cols for each component for calculations
% The HLC is constant over all 24 rows.
for i = 1:numOpaque
    OpaqueHLC(i) = obj.OpaqueSurfaces(i).HeatLossCoeff;
    OpaqueTypes(i) = obj.OpaqueSurfaces(i).OpaqueSurfaceType;
end

for i = 1:numGlazed
    GlazedHLC(i) = obj.GlazedSurfaces(i).HeatLossCoeff;
    GlazedTypes(i) = obj.GlazedSurfaces(i).GlazingType;
end

%slab heat loss if any. if there is no slab on grade, this is 0.
for i = 1:numSlab
    SlabHLC(i) = obj.SlabOnGrade(i).HeatLossCoeff;
end

OpaqueHLC = OpaqueHLC .* ones(24,numOpaque);
GlazedHLC = GlazedHLC .* ones(24,numGlazed);
SlabHLC = SlabHLC .* ones(24,numSlab);

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

[ACHnatHtg, ~] = obj.calculateInfiltration();
airLeakageFlow = ACHnatHtg * obj.IntVolume_ft3/60;
comboFlow = sqrt(airLeakageFlow.^2 + obj.HtngVentilationFlow(:,2).^2) + ...
    obj.HtngVentilationFlow(:,1);
HLCairHtg = 1.08 * comboFlow;

% Declaring matrices for storing the heat losses for day and night
% components in rows, day and night times for each month in 24 rows of
% above grade conductive parts of heat loss, including slab on grade.
% In addition to these there are 4 more cols:
% 1 col for combined air flow due to mech ventilation and natural air
% leakage
% 2 col for below grade heat loss if any (walls and floor)
% 1 col of totals, all in kBtu
numHeatLosses = numOpaque + numGlazed + numSlab + 4;
HeatLoss = zeros(24,numHeatLosses);

% calculate heat loss for each component in kBtu
% HLC * HDD * 24 / 1000 = kBtu
HeatLoss(:,1:numOpaque) = OpaqueHLC .* hdd * 24/1000;
HeatLoss(:,numOpaque + 1:numOpaque + numGlazed) = ...
    GlazedHLC .* hdd * 24/1000;
HeatLoss(:,numOpaque + numGlazed + 1:numOpaque + numGlazed + numSlab) = ...
    SlabHLC .* hdd * 24/1000;
HeatLoss(:,numOpaque + numGlazed + numSlab + 1) = ...
    HLCairHtg .* hdd * 24/1000;
HeatLoss(:,numOpaque + numGlazed + numSlab + 2) = BGwallHL24;
HeatLoss(:,numOpaque + numGlazed + numSlab + 3) = BGfloorHL24;

HeatLoss(:,numHeatLosses) = sum(HeatLoss(:,1:numHeatLosses),2);
heatLoss24 = HeatLoss(:,numHeatLosses);

% combining the total building heat loss for day and night, for use with
% utilization factors which are derived for the month as a whole
heatLoss12 = HeatLoss(1:2:23,numHeatLosses) + ...
    HeatLoss(2:2:24,numHeatLosses);

%% HeatLoss Sections
% Make a matrix containing the heat loss components as columns(summing up
% the diffeent objects of the same component)
 %opaque_tot = HeatLoss(:,1:numOpaque);
 %glazed_tot = HeatLoss(:,numOpaque + 1:numOpaque + numGlazed);

slab_tot = sum(HeatLoss(:,numOpaque + numGlazed + 1:numOpaque + numGlazed + numSlab),2);
airHtg_tot = sum(HeatLoss(:,numOpaque + numGlazed + numSlab + 1),2);
BG_tot = sum(HeatLoss(:,[numOpaque + numGlazed + numSlab + 2 numOpaque + numGlazed + numSlab + 3]),2);

% Get unique types
% Initialize as empty enum arrays (not double arrays)
uniqueOpaque = ece.enum.OpaqueSurfaceType.empty(1,0);
uniqueGlazed = ece.enum.GlazingType.empty(1,0);
% Sort and find unique values

for i = 1:length(OpaqueTypes)
    found = false;
    for j = 1:length(uniqueOpaque)
        if OpaqueTypes(i) == uniqueOpaque(j)
            found = true;
            break;
        end
    end
    if ~found
        uniqueOpaque(end+1) = OpaqueTypes(i);
    end
end


for i = 1:length(GlazedTypes)
    found = false;
    for j = 1:length(uniqueGlazed)
        if GlazedTypes(i) == uniqueGlazed(j)
            found = true;
            break;
        end
    end
    if ~found
        uniqueGlazed(end+1) = GlazedTypes(i);
    end
end
% Initialize result
aggregatedData = [];
columnNames = {};

% Aggregate opaque surfaces
for i = 1:length(uniqueOpaque)
    indices = find(OpaqueTypes == uniqueOpaque(i));
    aggregatedData(:, end+1) = sum(HeatLoss(:, indices), 2);
    columnNames{end+1} = char(uniqueOpaque(i).DisplayName);
end

% Aggregate glazing
glazingStart = length(OpaqueTypes) + 1;
for i = 1:length(uniqueGlazed)
    indices = find(GlazedTypes == uniqueGlazed(i)) + length(OpaqueTypes);
    aggregatedData(:, end+1) = sum(HeatLoss(:, indices), 2);
    columnNames{end+1} = char(uniqueGlazed(i).DisplayName);
end

%Adding rest of the Heat loss components to the columnNAmes array
columnNames{end+1} = char("Slabs");
columnNames{end+1} = char("Ventilation-Infiltration");
columnNames{end+1} = char("BelowGradeSurfaces");

%Putting all the HL components in a single matrix
HeatLoss_matrix24 = [aggregatedData slab_tot airHtg_tot BG_tot ];
%Adding up night and day components to get 12 rows
HeatLoss_matrix12 = HeatLoss_matrix24(1:2:23,:) + ...
    HeatLoss_matrix24(2:2:24,:);



%Assigning heatLoss components array to the property table
mnth = ["January","February","March","April","May","June",...
    "July","August","September","October","November","December"];

obj.HeatLossComponentsTable = array2table(HeatLoss_matrix12,'VariableNames', ...
    columnNames,"RowNames",mnth);



% Also convert internal gains to monthly basis for utilization factors.
intGainsHtgSeason12 = intGainsHtgSeason24(1:2:23) + ...
    intGainsHtgSeason24(2:2:24);

% Call the calculate heating utilization factors method which is in the
% buildings folder.
[intGainsUtilHtg, solarGainsUtilHtg] = ...
    obj.calculateHeatingUtilizationFactors(heatLoss12, ...
    intGainsHtgSeason12, solarGainsHtgSeason12);

% Energy balance for the day and night periods of each month
% Internal gains utilization factors are assumed equal for day and night.
intGainsUtilHtg24 = zeros(24,1);
intGainsUtilHtg24(1:2:23) = intGainsUtilHtg;
intGainsUtilHtg24(2:2:24) = intGainsUtilHtg;

% Solar gains utilization applies only to time 1 period (daytime).
solarGainsUtilHtg24 = zeros(24,1);
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
% WeatherMonthly property of Building.
OAT24 = obj.WeatherMonthly(4,:)';

% Initialize arrays.
numSys = length(obj.HeatCool);
htgInput24 = zeros(24,numSys);
sysEff24 = zeros(24,numSys);
sysCurveAll = zeros(5,numSys);

% Make an array with the efficiency curves for each system (column)
% 5 rows for the coefficients. Polynomial function of OAT.
% C1*OAT^4 + C2*OAT^3 + C3*OAT^2 + C4*OAT + C5
for sysIdx = 1:numSys
    sysCurveAll(:,sysIdx) = obj.HeatCool(sysIdx).HeatingEfficiencyCurve(:);
end   % for loop

% Calculate the heating efficiency for each system for each time period.
for sysIdx = 1:numSys
    sysEff24(:,sysIdx) = sysCurveAll(1,sysIdx) .* OAT24.^4 + ...
        sysCurveAll(2,sysIdx) .* OAT24.^3 + ...
        sysCurveAll(3,sysIdx) .* OAT24.^2 + ...
        sysCurveAll(4,sysIdx) .* OAT24 + ...
        sysCurveAll(5,sysIdx);
end   % for loop

% The load placed on the boiler includes the distribution losses.
% Multiply the heating efficiency by the distribution efficiency to get
% overall or total efficiency. Use an array of the distribution efficiencies.
totalEff24 = [obj.HeatCool.DistEffHtg] .* sysEff24;

%Find the input energy for each system based on fraction of load served
% and total efficiency. kBtu
for sysIdx = 1:numSys
    htgInput24(:,sysIdx) = ...
        (obj.HeatCool(sysIdx).HeatFrac * netHtgLoad24) ./ ...
        totalEff24(:,sysIdx);
end   % for loop

% As a check, note the total distribution losses as a fraction of the
% net heating load on the spaces. kBtu
% ALTER THIS - USE NET HEATING LOAD
distLosses = ([obj.HeatCool.HeatFrac] * sum(heatLoss24)) .* ...
    (1 - [obj.HeatCool.DistEffHtg]);
distLosses = fillmissing(distLosses, 'constant', 0);
distLossSum = sum(distLosses);
distLossFrac = distLossSum / sum(heatLoss24);

% Create Month Column for All Usages
usageTablePeriods = ["January","February","March","April","May","June",...
    "July","August","September","October","November","December",...
    "Annual"];

% The 24 time periods have served their purpose. Results will be reported
% in monthly form. Convert heating input24 to input12. Add annual and
% monthly totals.
htgInput12 = htgInput24(1:2:23,:) + htgInput24(2:2:24,:);
htgInput12 = fillmissing(htgInput12, "constant", 0);
htgInput12MonthTotals = [htgInput12, sum(htgInput12, 2)];

% Make a table for monthly heating input for each system with annual
% totals. Show system name, type, and load fraction.
heatSystemNames = [obj.HeatCool.Name, "Monthly Totals"]';
heatSystemTypes = [obj.HeatCool.SystemType, "All"]';

loadFracs = fillmissing([obj.HeatCool.HeatFrac], 'constant', 0);
allLoadFractions = [loadFracs, sum(loadFracs)]';

% Compute annual roll-up of monthly heating inputs.
annualHtgInputs = sum(htgInput12MonthTotals,1);
fullHtg12MonthTotals = [htgInput12MonthTotals;annualHtgInputs];

% MonthTable
monthHeatingTable = array2table(fullHtg12MonthTotals',...
    "VariableNames",usageTablePeriods);

% SystemTable
systemTable = table(...
    heatSystemNames,heatSystemTypes,allLoadFractions,...
    'VariableNames',["Heat System Name","System Type","Load Fraction"]);

% Space Heating Table
spaceHeatingTable = [systemTable,monthHeatingTable];

% Zero out some rows where the load fractions are zero.
spaceHeatingTable(allLoadFractions == 0, :) = [];


% -- Monthly Energy Use
% Make a table for monthly energy use by fuel type, gas or electric.
monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]';

% Convert the monthly input for each energy source into the appropriate units.
htgInput12Elec = ([obj.HeatCool.EnergySource] == "Electricity") ...
    .* htgInput12 * 1000/3413;                          % kWh (3,413 Btu)

htgInput12Gas = ([obj.HeatCool.EnergySource] == "Gas") ...
    .* htgInput12 * 1000/100000;                        % therms (100,000 Btu)

htgInput12HeatingOil = ([obj.HeatCool.EnergySource] == "HeatingOil") ...
    .* htgInput12 * 1000/138500;                        % gallons (138,500 Btu)

htgInput12Propane = ([obj.HeatCool.EnergySource] == "Propane") ...
    .* htgInput12 * 1000/91500;                         % gallons (91,000 Btu)

% Sum the monthly usage for all heating units.
htgInput12ElecAll = sum(htgInput12Elec,2);
htgInput12GasAll = sum(htgInput12Gas,2);
htgInput12HeatingOilAll = sum(htgInput12HeatingOil,2);
htgInput12PropaneAll = sum(htgInput12Propane,2);

% Compute and add the electricity used by the controls on the systems.
% Fuel systems using gas or oil use a small amount of electricity for
% controls and any small internal pumps.
% Remove cooling only systems from this. Their controls energy will be
% added in the calc space cooling energy function.
heatControlsElec = [obj.HeatCool.ControlskW] .* (24 * monthDays);
heatControlsElec = ([obj.HeatCool.SystemFunction] ~= "CoolingOnly") ...
    .* heatControlsElec;
heatControlsElecAll = sum(heatControlsElec,2);

% Add the minor electricity use for controls to the electric use (if any)
% of the heating system.
htgInput12ElecAll = htgInput12ElecAll + heatControlsElecAll;

% Arrange the data so it can be put into a table.
fuelArray = [htgInput12ElecAll, htgInput12GasAll,...
    htgInput12HeatingOilAll,htgInput12PropaneAll];

% Sum the Fuel Arrays across Rows after converting to kBtu
fuelArray_kBtu = sum([...
    (fuelArray(:,1) * 3413/1000),...
    (fuelArray(:,2) * 100),...
    (fuelArray(:,3) * 139000/1000),...
    (fuelArray(:,4) * 91000/1000)],2);

% Organize the Data
% Add column at end for utility roll-up
fuelArray = [fuelArray, fuelArray_kBtu];
% Add row to bottom for annual roll-up.
fuelArray = [fuelArray; sum(fuelArray)];

% Make a table of heating energy usage by fuel type.
heatFuelTblVarNames = ["Electricity_kWh", "Gas_therms", "HeatingOil_gallons", ...
    "Propane_gallons", "TotalEnergy_kBtu"]';

% Create table from numeric results, then add string column.
heatFuelTable = array2table(fuelArray,...
    "VariableNames",heatFuelTblVarNames);
heatFuelTable = addvars(heatFuelTable,...
    usageTablePeriods',...
    'Before',1,...
    'NewVariableNames',"Period");

% Write values to building properties.
obj.SpaceHeatingTable_kBtu = spaceHeatingTable;
obj.HeatFuelTable = heatFuelTable;


end  % function end statement