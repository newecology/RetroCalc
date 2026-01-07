function calculateInternalGainsAndElec(obj)
% this function calculates monthly building electric use and associated
% internal gains for use in space heating and cooling calcs, and provides
% a breakout of electricity and internal gains by component
% for each end use, there is a 4x12 matrix. 1st row - total electric in kWh, 2nd
% row heating sensible internal gains in kBtu, 3rd row cooling sensible and
% latent internal gains in kBtu.  4th row latent internal gains.
% these are combined for annual, monthly, and component totals

lightingElec = zeros(12,1);
lightingIntGainsSens = zeros(12,1);
EPDelec = zeros(12,1);
EPDintGainsSens = zeros(12,1);
peopleIntGainsSens = zeros(12,1);
peopleIntGainsLat = zeros(12,1);
airmoversElec = zeros(12,1);
airmoversIntGainsSens = zeros(12,1);
pumpsElec = zeros(12,1);
pumpsIntGainsSens = zeros(12,1);
applElec = zeros(12,1);
applIntGainsSens = zeros(12,1);
applIntGainsLat = zeros(12,1);
DHWelec12 = zeros(12,1);
DHWintGainsSens12 = zeros(12,1);


heatingElec = zeros(12,1);
coolingElec = zeros(12,1);
HVACcontrolsIntGainsSens = zeros(12,1);
exteriorLightingElec = zeros(12,1);
otherElec = zeros(12,1);
otherIntGainsSens = zeros(12,1);
otherIntGainsLat = zeros(12,1);
elecUsage = zeros(12,1);
heatingIntGains = zeros(12,1);
coolingTotalIntGains = zeros(12,1);
coolingLatentIntGains = zeros(12,1);
daysMonth = [31,28,31,30,31,30,31,31,30,31,30,31]';
numMonth = (1:12)';

% Normalize the estimates of the number of people in each space to equal
% the user entered total number of building occupants (if entered).
estPeopleEachSpace = [obj.Spaces.Area_ft2] ./ [obj.Spaces.Ft2person];
if isnan(obj.NumberOfOccupants)
    peopleEachSpace = estPeopleEachSpace;
else
    peopleEachSpace = estPeopleEachSpace .* (obj.NumberOfOccupants ...
        / sum(estPeopleEachSpace));
end    % if statement

%Lighting electric usage and internal gains
%adjust lighting for seasonal variation
%ratio of lighting max hours (Dec) to min hours (June)
lgtRatio = 1.2;
lgtAmpltd = lgtRatio - 1;
lgtMin = 1- (lgtAmpltd/2);
lgtRatioMonth = lgtMin + lgtAmpltd/2 + (lgtAmpltd/2) *(cos(numMonth*pi/6));

for spaceIdx = 1: length(obj.Spaces)
    lightingElecSpace(spaceIdx) = obj.Spaces(spaceIdx).LPD_Wft2 * ...
        obj.Spaces(spaceIdx).Area_ft2 * ...
        obj.Spaces(spaceIdx).LgtEFLHday / 1000;                       %kWh/day
end   % for loop

lightingElec = sum(lightingElecSpace) .* ...
    daysMonth .* ...
    lgtRatioMonth;  %kWh

lightingIntGainsSens = lightingElec * 3.413;                 %kBtu

% miscellaneous equipment (plug loads) electric usage and internal gains
for spaceIdx = 1: length(obj.Spaces)
    EPDelecSpace(spaceIdx) = obj.Spaces(spaceIdx).EPD_Wft2 * ...
        obj.Spaces(spaceIdx).Area_ft2 * ...
        obj.Spaces(spaceIdx).EquipEFLHday / 1000;                     %kWh/day

end   % for loop

EPDelec = sum(EPDelecSpace) .* daysMonth .* lgtRatioMonth;       %kWh
EPDintGainsSens = EPDelec * 3.413;                              %kBtu

% people internal gains
for spaceIdx = 1:length(obj.Spaces)
    peopleIntGainsSensSpace(spaceIdx) = obj.Spaces(spaceIdx).SensGain_BtuHrPerson * ...
        obj.Spaces(spaceIdx).PeopleEFLHday * ...
        peopleEachSpace(spaceIdx) / 1000;   %kBtu/day

    peopleIntGainsLatSpace(spaceIdx) = obj.Spaces(spaceIdx).LatGain_BtuHrPerson * ...
        obj.Spaces(spaceIdx).PeopleEFLHday * ...
        peopleEachSpace(spaceIdx) /1000;                   %kBtu/day

end % for loop

peopleIntGainsSens = sum(peopleIntGainsSensSpace) .*daysMonth;      %kBtu
peopleIntGainsLat = sum(peopleIntGainsLatSpace) .*daysMonth;        %kBtu

% Adding the airmovers (fans) electricity and sensible heat
numAirMovers = length(obj.Airmovers);
airMoversElecEach = zeros(12,numAirMovers);
airMoversIntGainsSensEach = zeros(12,numAirMovers);

for airMoverIdx = 1:numAirMovers
    airMoversElecEach(:,airMoverIdx) = obj.Airmovers(airMoverIdx).MonthlyKWH;
    airMoversIntGainsSensEach(:,airMoverIdx) = obj.Airmovers(airMoverIdx).InternalGains_kBtu;
end   % for loop

airMoversElec = sum(airMoversElecEach,2);
airMoversIntGainsSens = sum(airMoversIntGainsSensEach,2);

% Pumps electricity and internal gains
numPumps = length(obj.Pumps);
pumpsElecEach = zeros(12,numPumps);
pumpsIntGainsSensEach = zeros(12,numPumps);

for pumpIdx = 1:numPumps
    pumpsElecEach(:,pumpIdx) = obj.Pumps(pumpIdx).MonthlyKWH;
    pumpsIntGainsSensEach(:,pumpIdx) = obj.Pumps(pumpIdx).InternalGains_kBtu;
end

pumpsElec = sum(pumpsElecEach,2);
pumpsIntGainsSens = sum(pumpsIntGainsSensEach,2);

% Appliances electricity and internal gains
% Already calculated and passed to building. Extract array form, and
% transpose to ensure months are across rows and columns are the different
% properties.
applArray = table2array(obj.ApplianceEnergyTable12)';
applElec = applArray(:,1);
applIntGainsSens = applArray(:,3);
applIntGainsLat = applArray(:,4);

% DHW electric use. If the building has electric DHW heaters, it is accounted
% for here, as well as a small amount of energy from controls and any
% small internal pumps. Information is stored in building class in the
% DHWfuelTable. kWh

DHWelec12 = table2array(obj.DHWfuelTable(obj.DHWfuelTable.DHWfuelType == ...
    "Electricity_kWh", 2:13))';

% DHW internal gains (all sensible). kBtu
% Get the internal gains from the DHWenergyUsageTable
DHWintGainsSens12 = table2array(obj.DHWenergyUsageTable...
    (obj.DHWenergyUsageTable.DHWenergy_kBtu == "Internal gains DHW", 2:13))';

% Heating and cooling systems electric usage added later.

% placeholder for exterior lighting if any

% placeholder for other electricity users or sources of internal heat

% make arrays of the components of electric use and internal gains
elecUsageComponents = [...
    lightingElec,...
    EPDelec,...
    airMoversElec,...
    pumpsElec,...
    applElec,...
    DHWelec12,...
    heatingElec,...
    coolingElec,...
    exteriorLightingElec,...
    otherElec];

% Get Total Elec Usage Monthly
elecUsage = sum(elecUsageComponents,2);

intGainsSensComponents = [...
    lightingIntGainsSens,...
    EPDintGainsSens,...
    peopleIntGainsSens,...
    airMoversIntGainsSens,...
    pumpsIntGainsSens,...
    applIntGainsSens,...
    DHWintGainsSens12,...
    HVACcontrolsIntGainsSens,...
    otherIntGainsSens];

heatingIntGains = sum(intGainsSensComponents,2);

intGainsLatComponents = [...
    peopleIntGainsLat,...
    applIntGainsLat,...
    otherIntGainsLat];

coolingLatentIntGains = sum(intGainsLatComponents,2);

% Compute Total Latent Gains
coolingTotalIntGains = heatingIntGains + coolingLatentIntGains;

% Monthly internal gains array for use in calculations.
% Col 1 sensible gains for heating calculations
% Col 2 sensible and latent gains for cooling calculations
% Col 3 latent gains only to determine sensible fraction if needed
internalGains = ...
    [heatingIntGains, coolingTotalIntGains, coolingLatentIntGains];

% Create Period Column for All Usages
usageTablePeriods = ["January","February","March","April","May","June",...
    "July","August","September","October","November","December",...
    "Annual"]';

% Make tables of component electric usage by month and with annual and
% component totals. All in kWh.
electricUsageTableVarNames = ["Lights","PlugLoads","Fans",...
    "Pumps","Appliances","DHW","SpaceHeating","SpaceCooling",...
    "ExteriorLights","OtherElec","MonthlyTotals"];

%define variables for each month to make the table
elecUseCompsWTotals = [elecUsageComponents, sum(elecUsageComponents,2)];
% Sum each column to create 13th Annual Total Row
elecUseCompsWTotals = [elecUseCompsWTotals; sum(elecUseCompsWTotals,1)];

% Create Elec Monthly/Annual Usage Table
elecUsageTbl = array2table(elecUseCompsWTotals,...
    "VariableNames",electricUsageTableVarNames);
elecUsageTbl = addvars(elecUsageTbl,...
    usageTablePeriods,...
    'Before',1,...
    'NewVariableNames',"Period");

% Write electric usage table to building table
obj.ElectricUsageTable = elecUsageTbl;

% Similar table for internal gains. All in kBtu.
internalGainsUsageTableVarNames = ["Lights","Plug Loads",...
    "People Sensible","Fans","Pumps","Appliances Sensible","DHW",...
    "HVAC Controls","Other Sensible","People Latent","Appliances Latent",...
    "Other Latent","Sensible Totals","Latent Totals",...
    "Sensible and Latent Totals"];

% Define variables for each month tomake the table
intGainsComponents = [intGainsSensComponents, intGainsLatComponents, ...
    heatingIntGains, coolingLatentIntGains, coolingTotalIntGains];
% Sum each column to create 13th Annual Total Row
intGainsComponents = [intGainsComponents; sum(intGainsComponents)];

% Create Int. Gains Monthly/Annual Usage Table
intGainsTable = array2table(intGainsComponents,...
    "VariableNames",internalGainsUsageTableVarNames);
intGainsTable = addvars(intGainsTable,...
    usageTablePeriods,...
    'Before',1,...
    'NewVariableNames',"Period");


% Write internal gains table to building table
obj.InternalGainsTable = intGainsTable;

% Convert the 12 month internal gains quantities to 24 time periods
% (Jan day, Jan night, Feb day, etc.) according to the fraction of time 1
% and 2 periods.
% For now assume that internal gains are equally distributed
% between day and night periods.
% Later, day/night weighting factors for lighting, equipment, and people,
% can be added if necessary. However from an examination of typical
% residential lighting schedules, it appears that usage is approximately
% 50/50 day night for time period 1 of 6am-6pm, or 7am-7pm, or 8am-8pm

% time fractions for periods 1 and 2 to allot internal gains
time1Frac = (obj.HVACStartEndTimePeriod1(2) - ...
    obj.HVACStartEndTimePeriod1(1)) / 24;
time2Frac = 1 - time1Frac;

%internal gains are assumed relatively constant and divided into time
%periods 1 and 2 by number of hours
% future work. incorporate typical daily load profiles of internal gains
% in order to allocate gains to day/night periods
internalGains24 = zeros(24,3);
internalGains24(1:2:23,:) = internalGains * time1Frac;
internalGains24(2:2:24,:) = internalGains * time2Frac;

obj.InternalGainsArray_kBtu = internalGains24;

end  % function statement
