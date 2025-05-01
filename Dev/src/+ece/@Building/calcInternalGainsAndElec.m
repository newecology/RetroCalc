function calcInternalGainsAndElec(obj)

% this function calculates monthly building electric use and associated 
% internal gains for use in space heating and cooling calcs, and provides
% a breakout of electricity and internal gains by component
% for each end use, there is a 4x12 matrix. 1st row - total electric in kWh, 2nd
% row heating sensible internal gains in kBtu, 3rd row cooling sensible and
% latent internal gains in kBtu.  4th row latent internal gains. 
% these are combined for annual, monthly, and component totals

lightingElec = zeros(1,12);
lightingIntGainsSens = zeros(1,12);
EPDelec = zeros(1,12);
EPDintGainsSens = zeros(1,12);
peopleIntGainsSens = zeros(1,12);
peopleIntGainsLat = zeros(1,12);
airmoversElec = zeros(1,12);
airmoversIntGainsSens = zeros(1,12);
pumpsElec = zeros(1,12);
pumpsIntGainsSens = zeros(1,12);
applElec = zeros(1,12);
applIntGainsSens = zeros(1,12);
applIntGainsLat = zeros(1,12);
DHWelec12 = zeros(1,12);
DHWintGainsSens12 = zeros(1,12);
heatingElec = zeros(1,12);
coolingElec = zeros(1,12);
HVACcontrolsIntGainsSens = zeros(1,12);
exteriorLightingElec = zeros(1,12);
otherElec = zeros(1,12);
otherIntGainsSens = zeros(1,12);
otherIntGainsLat = zeros(1,12);
elecUsage = zeros(1,12);
heatingIntGains = zeros(1,12);
coolingTotalIntGains = zeros(1,12);
coolingLatentIntGains = zeros(1,12);
daysMonth = [31,28,31,30,31,30,31,31,30,31,30,31];
numMonth = [1:12];

% Normalize the estimates of the number of people in each space to equal
% the user entered total number of building occupants (if entered).
estPeopleEachSpace = [obj.Spaces.Area_ft2] ./ [obj.Spaces.Ft2person];
if isnan(obj.BldgNumberOfOccupants) 
    peopleEachSpace = estPeopleEachSpace;
else 
    peopleEachSpace = estPeopleEachSpace .* (obj.BldgNumberOfOccupants ...
        / sum(estPeopleEachSpace));
end    % if statement

%Lighting electric usage and internal gains
%adjust lighting for seasonal variation
%ratio of lighting max hours (Dec) to min hours (June)
lgtRatio = 1.2;
lgtAmpltd = lgtRatio - 1;
lgtMin = 1- (lgtAmpltd/2);
lgtRatioMonth = lgtMin + lgtAmpltd/2 + (lgtAmpltd/2) *(cos(numMonth*pi/6));

for i = 1: length(obj.Spaces)
   lightingElecSpace(i) = obj.Spaces(i).LPD_Wft2 * obj.Spaces(i).Area_ft2 * ...
       obj.Spaces(i).LgtEFLHday /1000;                       %kWh/day
end   % for loop
lightingElec = sum(lightingElecSpace) .*daysMonth .* lgtRatioMonth;  %kWh
lightingIntGainsSens = lightingElec * 3.413;                 %kBtu

% miscellaneous equipment (plug loads) electric usage and internal gains
for i = 1: length(obj.Spaces)
   EPDelecSpace(i) = obj.Spaces(i).EPD_Wft2 * obj.Spaces(i).Area_ft2 * ...
       obj.Spaces(i).EquipEFLHday /1000;                     %kWh/day
end   % for loop
EPDelec = sum(EPDelecSpace) .*daysMonth .* lgtRatioMonth;       %kWh
EPDintGainsSens = EPDelec * 3.413;                              %kBtu

% people internal gains
for i = 1: length(obj.Spaces)
   peopleIntGainsSensSpace(i) = obj.Spaces(i).SensGain_BtuHrPerson * obj.Spaces(i).PeopleEFLHday * ...
       peopleEachSpace(i) /1000;                     %kBtu/day 
   peopleIntGainsLatSpace(i) = obj.Spaces(i).LatGain_BtuHrPerson * obj.Spaces(i).PeopleEFLHday ...
       * peopleEachSpace(i) /1000;                   %kBtu/day
end   % for loop
peopleIntGainsSens = sum(peopleIntGainsSensSpace) .*daysMonth;      %kBtu
peopleIntGainsLat = sum(peopleIntGainsLatSpace) .*daysMonth;        %kBtu

% Adding the airmovers (fans) electricity and sensible heat
airMoversElecEach = zeros(length(obj.Airmovers), 12);
airMoversIntGainsSensEach = zeros(length(obj.Airmovers), 12);

for i = 1:length(obj.Airmovers)
  airMoversElecEach(i,:) = obj.Airmovers(i).MonthlyKWH;
  airMoversIntGainsSensEach(i,:) = obj.Airmovers(i).InternalGains_kBtu; 
end   % for loop

airMoversElec = sum(airMoversElecEach);
airMoversIntGainsSens = sum(airMoversIntGainsSensEach);

% Pumps electricity and internal gains
pumpsElecEach = zeros(length(obj.Pumps), 12);
pumpsIntGainsSensEach = zeros(length(obj.Pumps), 12);

for i=1:length(obj.Pumps)
  pumpsElecEach(i,:) = obj.Pumps(i).MonthlyKWH;
  pumpsIntGainsSensEach(i,:) = obj.Pumps(i).InternalGains_kBtu;
end

pumpsElec = sum(pumpsElecEach);
pumpsIntGainsSens = sum(pumpsIntGainsSensEach);

% Appliances electricity and internal gains
% Already calculated and passed to building

applArray = table2array(obj.ApplianceEnergyTable12);
applElec = applArray(1,:); 
applIntGainsSens = applArray(3,:);
applIntGainsLat = applArray(4,:);

% DHW electric use. If the building has electric DHW heaters, it is accounted
% for here, as well as a small amount of energy from controls and any 
% small internal pumps. Information is stored in building class in the
% DHWfuelTable. kWh

DHWelec12 = table2array(obj.DHWfuelTable(obj.DHWfuelTable.DHWfuelType == ...
    "Electricity_kWh", 2:13));

% DHW internal gains (all sensible). kBtu
% Get the internal gains from the DHWenergyUsageTable
DHWintGainsSens12 = table2array(obj.DHWenergyUsageTable...
 (obj.DHWenergyUsageTable.DHWenergy_kBtu == "Internal gains DHW", 2:13));

% Heating and cooling systems electric usage added later.

% placeholder for exterior lighting if any

% placeholder for other electricity users or sources of internal heat

% make arrays of the components of electric use and internal gains
elecUsageComponents = [lightingElec; EPDelec; airMoversElec; pumpsElec; applElec; ...
    DHWelec12; heatingElec; coolingElec; exteriorLightingElec; otherElec];
elecUsage = sum(elecUsageComponents);

intGainsSensComponents = [lightingIntGainsSens; EPDintGainsSens; peopleIntGainsSens; ...
    airMoversIntGainsSens; pumpsIntGainsSens; applIntGainsSens; DHWintGainsSens12; ...
    HVACcontrolsIntGainsSens; otherIntGainsSens];
heatingIntGains = sum(intGainsSensComponents);

intGainsLatComponents = [peopleIntGainsLat; applIntGainsLat; otherIntGainsLat];
coolingLatentIntGains = sum(intGainsLatComponents);

coolingTotalIntGains = heatingIntGains + coolingLatentIntGains;

% Monthly internal gains array for use in calculations. 
% row 1 sensible gains for heating calculations
% row 2 sensible and latent gains for cooling calculations
% row 3 latent gains only to determine sensible fraction if needed
internalGains = [heatingIntGains; coolingTotalIntGains; coolingLatentIntGains];

% Make tables of component electric usage by month and with annual and 
% component totals. All in kWh.
electricLoadskWh = ["lights" "plug loads" "fans" "pumps" "appliances" ...
    "DHW" "space heating" "space cooling" "exterior lights" "other elec" "monthly totals"]';
%define variables for each month to make the table
elecUseCompsWTotals = [elecUsageComponents sum(elecUsageComponents,2)];
elecUseCompsWTotals = [elecUseCompsWTotals; sum(elecUseCompsWTotals)];

Jan=elecUseCompsWTotals(:,1);  Feb=elecUseCompsWTotals(:,2);  Mar=elecUseCompsWTotals(:,3);
Apr=elecUseCompsWTotals(:,4); May=elecUseCompsWTotals(:,5); Jun=elecUseCompsWTotals(:,6);
Jul=elecUseCompsWTotals(:,7); Aug=elecUseCompsWTotals(:,8); Sep=elecUseCompsWTotals(:,9);
Oct=elecUseCompsWTotals(:,10); Nov=elecUseCompsWTotals(:,11); Dec=elecUseCompsWTotals(:,12);
annualTotals = elecUseCompsWTotals(:,13); 

elecUsageTbl = table(electricLoadskWh, Jan, Feb, Mar, Apr, May, Jun, ...
    Jul, Aug, Sep, Oct, Nov, Dec, annualTotals);

% Write electric usage table to building table
obj.ElectricUsageTable = elecUsageTbl; 

% Similar table for internal gains. All in kBtu.
internalGains_kBtu = ["lights" "plug loads" "people sensible"  ...
    "fans" "pumps" "appliances sensible" "DHW" "HVAC controls" ...
    "other sensible" "people latent" "appliances latent" ...
    "other latent" "sensible totals" "latent totals" ...
    "sensible and latent totals"]';
intGainsComponents = [intGainsSensComponents; intGainsLatComponents; ...
    heatingIntGains; coolingLatentIntGains; coolingTotalIntGains];
intGainsComponents = [intGainsComponents sum(intGainsComponents, 2)];

Jan=intGainsComponents(:,1);  Feb=intGainsComponents(:,2);  Mar=intGainsComponents(:,3);
Apr=intGainsComponents(:,4); May=intGainsComponents(:,5); Jun=intGainsComponents(:,6);
Jul=intGainsComponents(:,7); Aug=intGainsComponents(:,8); Sep=intGainsComponents(:,9);
Oct=intGainsComponents(:,10); Nov=intGainsComponents(:,11); Dec=intGainsComponents(:,12);
annualTotals = intGainsComponents(:,13); 

intGainsTable = table(internalGains_kBtu, Jan, Feb, Mar, Apr, May, Jun, ...
    Jul, Aug, Sep, Oct, Nov, Dec, annualTotals);

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
  time1Frac = (obj.HVACStartEndTimePeriod1(2) - obj.HVACStartEndTimePeriod1(1))/24;
  time2Frac = 1 - time1Frac;
  
  %internal gains are assumed relatively constant and divided into time
  %periods 1 and 2 by number of hours
  % future work. incorporate typical daily load profiles of internal gains
  % in order to allocate gains to day/night periods
  internalGains24 = zeros(3,24);
  internalGains24(:, 1:2:23) = internalGains * time1Frac;
  internalGains24(:, 2:2:24) = internalGains * time2Frac;

  obj.InternalGainsArray_kBtu = internalGains24;

end  % function statement
