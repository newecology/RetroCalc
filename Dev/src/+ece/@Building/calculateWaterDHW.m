function calculateWaterDHW(obj)
% Calculate water usage by fixture, monthly and annual totals
% Calculate water heater input energy and internal gains associated with
% the DHW system(s)
% Method to compute this within a building object. 
%this function takes inputs from 1) DHW system parameters
% such as efficiency, circulation losses, tank types, etc, 2) plumbing 
% fixtures - flow rate and amount of usage on each, 3) piping lengths
% in the mechanical room, 4) heat loss from bare and insulated pipes 
% of various sizes.
%it calculates the water and energy usage for each fixture type as well
%boiler room standby and distribution/circulation system losses. These
%can be compared to utility data for water and DHW energy to calibrate.
%it also finds the heat losses from the DHW system that need to be counted
%as internal gains



%% Arguments Block
arguments
    % Obj - Self-referential building object.
    obj (1,1) ece.Building
end %argblock

%% Variables use in calculation

% the total water usage and DHW energy load for the whole building will be calclated
% if there is more than one DHW system, input energy will be found for each
% system based on the fraction of load that it serves

% number of DHW systems
numDHWsystems = height(obj.DHWsystems);

% parameters for the building as a whole, based on primary DHW system
TcMin = obj.DHWsystems(1).ColdWaterMinTempFeb_F;
TcMax = obj.DHWsystems(1).ColdWaterMaxTempAug_F;
TcDelta = TcMax - TcMin;
Th = obj.DHWsystems(1).HeaterOutputTemp_F;
ThCommlK = obj.DHWsystems(1).HeaterOutputTempCommlKitchen_F;
numUnits = obj.BldgNumberOfUnits;
numOcc = obj.BldgNumberOfOccupants;
daysMonth = [31 28 31 30 31 30 31 31 30 31 30 31];
summerPeakWaterDist = table2array(ece.Reference.SummerPeakWaterMonthDistTable);
PipeHeatLoss140FTbl = ece.Reference.PipeHeatLoss140FTable;

% parameters for each individual hot water heater
for n=1:numDHWsystems
    heaterType(n) = obj.DHWsystems(n).WaterHeaterType;
    recircYorN(n) = obj.DHWsystems(n).DHWrecirculation;
    recirType(n) = obj.DHWsystems(n).RecircLoopType;
    effDHW(n) = obj.DHWsystems(n).SteadyStateEfficiency;
    effDHWamp(n) = obj.DHWsystems(n).EfficiencySeasonalAmplitude;
    circLoss(n) = obj.DHWsystems(n).CircLossesJulyFracOfLoad;
    circLossAmp(n) = obj.DHWsystems(n).CircLossesSeasonalAmplitude;
    circFracCond(n) = obj.DHWsystems(n).CircLossesFracCond;
    controlskW(n) = obj.DHWsystems(n).ControlskW;
    fracLoadServed(n) = obj.DHWsystems(n).FractionBuildingLoadServed;
    
end      % for loop for DHW heaters

% add test? total fracLoadServed should add up to 1

% mechanical room heat losses to conditioned space estimated as average of that for the tanks
% average is weighted by the number of tanks
loss=0;
tankQty = 0;
for n = 1:height(obj.DHWtanks)
  loss(n) = obj.DHWtanks(n).FracCond * obj.DHWtanks(n).Quantity;
  tankQty = tankQty + obj.DHWtanks(n).Quantity;
end
mechRmFracCond = sum(loss) / tankQty;


%% Water Usage Annual

waterGallons = ["Toilets"; "Urinals"; "BathroomSink"; "KitchenSink"; "Shower";...
    "InUnitDishwasher"; "InUnitClotheswasher"; "CommonClotheswasher"; ...
    "CommercialKitchenSink"; "CommercialDishwasher"; "Irrigation"; "CoolingTower"; ...
    "Other"; "Totals"];

% initialize water usage to zero for all fixture types
waterToilets = 0; waterUrinals = 0; waterBsink = 0; waterKsink = 0; waterShower = 0; ...
    waterInUnitDishwasher = 0; waterInUnitClotheswasher = 0; waterCommonClotheswasher = 0; ...
    waterCommercialKitchenSink = 0; waterCommercialDishwasher = 0; ...
    waterCommercialDishwasher = 0; waterIrrigation = 0; waterCoolingTower = 0; ...
    waterOther = 0;

% set up array for fixture usage
waterUsage = zeros(14,13);

% Calculate water use for each fixture type, each is a variable, gallons
% per year.
% There could be more than one of a given fixture type, for example a
% building that has some low flow shower heads, and some high flow, or some
% low flow toilets, and some older. So use iterative summing.
for n=1:height(obj.PlumbingFixtures)
    if obj.PlumbingFixtures(n).PlumbingFixtureType == "Toilets"
        waterToilets = waterToilets + obj.PlumbingFixtures(n).Gallons * ...
            obj.PlumbingFixtures(n).Uses * numOcc * 365 ...
            * obj.PlumbingFixtures(n).FractionTotal;
    end
    if obj.PlumbingFixtures(n).PlumbingFixtureType == "Urinals"
        waterUrinals = waterUrinals + obj.PlumbingFixtures(n).Gallons * ...
            obj.PlumbingFixtures(n).Uses * numOcc * 365 ...
            * obj.PlumbingFixtures(n).FractionTotal;
    end
    if obj.PlumbingFixtures(n).PlumbingFixtureType == "BathroomSink"
        waterBsink = waterBsink + obj.PlumbingFixtures(n).Gallons * ...
            obj.PlumbingFixtures(n).Uses * numOcc * 365 ...
            * obj.PlumbingFixtures(n).FractionTotal;
    end
    if obj.PlumbingFixtures(n).PlumbingFixtureType == "KitchenSink"
        waterKsink = waterKsink + obj.PlumbingFixtures(n).Gallons * ...
            obj.PlumbingFixtures(n).Uses * numOcc * 365 ...
            * obj.PlumbingFixtures(n).FractionTotal;
    end
    if obj.PlumbingFixtures(n).PlumbingFixtureType == "Shower"
        waterShower = waterShower + obj.PlumbingFixtures(n).Gallons * ...
            obj.PlumbingFixtures(n).Uses * numOcc * 365 ...
            * obj.PlumbingFixtures(n).FractionTotal;
    end
    if obj.PlumbingFixtures(n).PlumbingFixtureType == "InUnitDishwasher"
        waterInUnitDishwasher = waterInUnitDishwasher + ...
            obj.PlumbingFixtures(n).Gallons * ...
            obj.PlumbingFixtures(n).Uses * numUnits * 52 ...
            * obj.PlumbingFixtures(n).FractionTotal;
    end
    if obj.PlumbingFixtures(n).PlumbingFixtureType == "InUnitClotheswasher"
        waterInUnitClotheswasher = waterInUnitClotheswasher + ...
            obj.PlumbingFixtures(n).Gallons * ...
            obj.PlumbingFixtures(n).Uses * numUnits * 52 ...
            * obj.PlumbingFixtures(n).FractionTotal;
    end
    if obj.PlumbingFixtures(n).PlumbingFixtureType == "CommonClotheswasher"
        waterCommonClotheswasher = waterCommonClotheswasher + ...
            obj.PlumbingFixtures(n).Gallons * ...
            obj.PlumbingFixtures(n).Uses * numUnits * 52 ...
            * obj.PlumbingFixtures(n).FractionTotal;
    end
    if obj.PlumbingFixtures(n).PlumbingFixtureType == "CommercialKitchenSink"
        waterCommercialKitchenSink = waterCommercialKitchenSink + ...
            obj.PlumbingFixtures(n).Gallons * ...
            obj.PlumbingFixtures(n).Uses * numOcc * 365 ...
            * obj.PlumbingFixtures(n).FractionTotal;
    end
    if obj.PlumbingFixtures(n).PlumbingFixtureType == "CommercialDishwasher"
        waterCommercialDishwasher = waterCommercialDishwasher + ...
            obj.PlumbingFixtures(n).Gallons * ...
            obj.PlumbingFixtures(n).Uses * numUnits * 52 ...
            * obj.PlumbingFixtures(n).FractionTotal;
    end
    if obj.PlumbingFixtures(n).PlumbingFixtureType == "Irrigation"
        waterIrrigation = waterIrrigation + ...
            obj.PlumbingFixtures(n).Gallons ...
            * obj.PlumbingFixtures(n).FractionTotal;
    end
    if obj.PlumbingFixtures(n).PlumbingFixtureType == "CoolingTower"
        waterCoolingTower = waterCoolingTower + ...
            obj.PlumbingFixtures(n).Gallons ...
            * obj.PlumbingFixtures(n).FractionTotal;
    end
    if obj.PlumbingFixtures(n).PlumbingFixtureType == "Other"
        waterOther = waterOther + obj.PlumbingFixtures(n).Gallons ...
            * obj.PlumbingFixtures(n).FractionTotal;
    end

end  % for loop    

waterUsage(1:13,13) = [waterToilets, waterUrinals, waterBsink, waterKsink, waterShower, ...
    waterInUnitDishwasher, waterInUnitClotheswasher, waterCommonClotheswasher, ...
    waterCommercialKitchenSink, waterCommercialDishwasher, waterIrrigation, ...
    waterCoolingTower, waterOther]';


%% Water Monthly Usage Array and Table
% array has monthly water use for each fixture type. last column is totals
% for fixture. last row is monthly total for all fixtures.
% first 10 rows are plumbing fixtures and water using appliances
for n = 1:10                                    
    waterUsage(n, 1:12) = waterUsage(n, 13) / 365 * daysMonth;
end
% rows 11 and 12 are irrigation and cooling tower - summer peaking
waterUsage(11:12, 1:12) = waterUsage(11:12, 13) .* summerPeakWaterDist;
% row 13 is "other" - any other water use assumed constant all year
waterUsage(13, 1:12) = waterUsage(13, 13) / 365 * daysMonth;
% row 14 is monthly totals
waterUsage(14, :) = sum(waterUsage(1:13, :), 1, 'omitNAN');

% put the array into a table for user review
water12Tbl = array2table(waterUsage, 'VariableNames', ...
    {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', ...
    'Oct', 'Nov', 'Dec', 'Annual'});
water12Tbl = addvars(water12Tbl, waterGallons, 'Before', 'Jan');


%% Energy to heat water

% this is load energy for the building as a whole. use Thot for DHW system number 1
% (load energy will be the same even with varying Thot)
% input energy will be calculated later for each DHW heater based on its
% efficiency and fraction of load served

%calculate monthly and annual energy use to heat DHW

%cold water (mains) temperature each month
TcMonth = TcMin + ((TcDelta/2) * (1+cos(([1:12]+5)*(pi/6))));

%temp at point of use for 8 fixture types that use hot water
for n = 1:8
Tuse(n) = obj.PlumbingFixtures(n+2).UseTemp_F;
end     % for loop
Tuse = Tuse';

%temp of hot water from the DHW heater. same for each fixture type except
%for commercial kitchen
ThVector = ones(8,1)*Th;
ThVector(8) = ThCommlK;

%fraction of water heated for each fixture type for each month
%(Tuse - TcMonth) is an 8 row 12 column array. for all 8 hot water using
% fixtures over 12 months. (ThVector -TcMonth) is also 8 row 12 column array
fracHot = (Tuse - TcMonth) ./ (ThVector - TcMonth);

%water heated for each hot using fixture type for each month, gallons
galHeated = fracHot .* waterUsage(3:10, 1:12);

%total amount of water heated that is used for the year for all fixtures
galHeatedTotalAnnual = sum(galHeated, 'all');

%total amount of water heated for each fixture type for the year
%the 2 means sum all columns for each row
galHeatedTotalFixtAnnual = sum(galHeated, 2);

%total amount of water heated that is used for each month (all fixtures)
%the 1 means sum all rows for each column
galHeatedTotal12 = sum(galHeated,1);

% "usage energy", kBtu
% energy to heat the water that is used. losses that are not dependent on
% usage are added as "circulation" and "mechanical room" losses
% note (ThVector - TcMonth) gives an 8x12 array
% column vector minus row vector
usageEnergyEachFixt12 = galHeated * 8.34 * 1 .* (ThVector - TcMonth) / 1000;

%water heated energy for each month for all fixtures combined, kBtu
%12 column row vector
usageEnergy12 = sum(usageEnergyEachFixt12, 1);

%water heated energy for each fixture for all months combined
%8 row column vector, kBtu
usageEnergyEachFixtAnnual = sum(usageEnergyEachFixt12, 2);

%% Heat losses from DHW mechanical room piping, tanks, and distribution piping

%add losses from tanks and piping in the mechanical room
%these are mostly independent of usage. use input data for tanks
%and piping lengths and diameters and insulaton status. 
%add tank heat loss to mechanical room piping heat loss
% kBtu

% domestic hot water tanks heat loss
numDHWtanks = height(obj.DHWtanks);
DHWtankLoss = zeros(1,numDHWtanks);
for n = 1:numDHWtanks
    DHWtankLoss(n) = obj.DHWtanks(n).Quantity * obj.DHWtanks(n).Volume_gal ...
        * 8.34 * 1 * (obj.DHWtanks(n).TankTemp_F - obj.DHWtanks(n).RefTemp_F) ...
        * obj.DHWtanks(n).PercentLossHr / 100 * obj.DHWtanks(n).HoursHot / 1000;
end  % for loop

totalDHWtankLoss = sum(DHWtankLoss);

% DHW pipes in mechanical room heat loss, kBtu
numDHWpipes = height(obj.DHWpipesMechRoom);
DHWpipeLoss = zeros(1,numDHWtanks);
for n = 1:numDHWpipes
    if obj.DHWpipesMechRoom(n).PipeType == 'CopperBare'
        DHWpipeLoss(n) = obj.DHWpipesMechRoom(n).Length_ft * ...
            PipeHeatLoss140FTbl.CopperBare(PipeHeatLoss140FTbl.PipeDiameter_inch == ...
            obj.DHWpipesMechRoom(n).PipeDiameter_inch) * ...
            obj.DHWpipesMechRoom(n).HoursHot / 1000;
    elseif  obj.DHWpipesMechRoom(n).PipeType == 'CopperInsul'
        DHWpipeLoss(n) = obj.DHWpipesMechRoom(n).Length_ft * ...
            PipeHeatLoss140FTbl.CopperInsul(PipeHeatLoss140FTbl.PipeDiameter_inch == ...
            obj.DHWpipesMechRoom(n).PipeDiameter_inch) * ...
            obj.DHWpipesMechRoom(n).HoursHot / 1000;
    elseif  obj.DHWpipesMechRoom(n).PipeType == 'SteelBare'
        DHWpipeLoss(n) = obj.DHWpipesMechRoom(n).Length_ft * ...
            PipeHeatLoss140FTbl.SteelBare(PipeHeatLoss140FTbl.PipeDiameter_inch == ...
            obj.DHWpipesMechRoom(n).PipeDiameter_inch) * ...
            obj.DHWpipesMechRoom(n).HoursHot / 1000;
    else   obj.DHWpipesMechRoom(n).PipeType == 'SteelInsul'
        DHWpipeLoss(n) = obj.DHWpipesMechRoom(n).Length_ft * ...
            PipeHeatLoss140FTbl.SteelInsul(PipeHeatLoss140FTbl.PipeDiameter_inch == ...
            obj.DHWpipesMechRoom(n).PipeDiameter_inch) * ...
            obj.DHWpipesMechRoom(n).HoursHot / 1000;
    end  % if statements
end  % for loop

totalMechRoomDHWpipeLoss = sum(DHWpipeLoss);

% add tank loss to pipe loss, kBtu/year for the whole building
% not linked to a particular water heater, if >1 water heaters
mechRoomEnergyLoss = totalDHWtankLoss + totalMechRoomDHWpipeLoss;

%split the annual loss into loss for each month (1x12 vector)
mechRmLoss12 = mechRoomEnergyLoss / 365 * daysMonth;

% add circulation losses at the system level, i.e. all fixtures, for each month
% circ losses are losses in the distribution piping outside the boiler room
% and are estimated as a fraction of fixture load
% circ losses are based on the average month. least in July, most in January
% largely due to recirculation systems
% units are kBtu, row vector with 12 columns

% DHWsystem.DHWrecirculation and DHWsystem.RecircLoopType are not currently
% used. They can be used for a validation check however
% if there is recirc
% CompactInsulated => circLoss = .05 - .15
% Average => circLoss = .15- .25
% LongRunsPoorlyInsulated => circLoss = .25 - .35
% if there is no recirc, circLoss = 0 -.15

circLoss12 = zeros(numDHWsystems,12);
% Average fixture load out over 12 months for use in finding circ losses.
% Circulation losses do not vary seasonally as much as usage energy.
% Calculate circ losses for each DHW system separately based on fraction of
% load served.
usageEnergyAvg = sum(usageEnergy12) / 12;

for n = 1:numDHWsystems
        circLoss12(n,:) = (usageEnergyAvg * circLoss(n)) * (1 + circLossAmp(n)/2 *...
            cos(([1:12]-1) * pi/6)) * obj.DHWsystems(n).FractionBuildingLoadServed;
end % for loop

%% DHW heater input energy

% add tank losses, mech room pipe losses, and circ losses to usage energy 
% apportion usage energy and mechanical room losses to each water heater if >1 heaters
% circulation losses are already apportioned.  kBtu

heaterLoadEnergy12 = zeros(numDHWsystems, 12);

for n = 1:numDHWsystems
    heaterLoadEnergy12(n,:) = ((usageEnergy12 + mechRmLoss12) * ...
       obj.DHWsystems(n).FractionBuildingLoadServed) + circLoss12(n,:);
end    % for loop

% validation check. for gas and electric heaters, amplitude of DHW efficiency should close to 0,
% probably less than .05. for heat pump water heaters the amplitude could be higher

%find water heater efficiency seasonal variation, if any (may not be any)
%rated steady state efficiency value is maximum in July.
effDHW12 = zeros(numDHWsystems, 12);
for n = 1:numDHWsystems
    effDHW12(n,:) = effDHW(n) * (1 - effDHWamp(n)/2 - (effDHWamp(n)/2 * cos(([1:12]-1)*pi/6)));
end  % for loop

%heater input energy by month, kBtu
DHWheaterInputEnergy12 = zeros(numDHWsystems, 12);
DHWheaterInputEnergy12 = heaterLoadEnergy12 ./ effDHW12;

% annual input energy in kBtu (for each water heater if >1 heaters)
DHWheaterInputAnnual_kBtu = sum(DHWheaterInputEnergy12, 2);
% total annual kBtu for all DHW
allDHWheatersInputAnnual_kBtu = sum(DHWheaterInputAnnual_kBtu);

% total annual DHW input energy, for each system and for all systems
% by energy type, which will be in kWh, therms, etc

DHWInput12_therms = zeros(numDHWsystems, 12);
DHWInput12_kWh = zeros(numDHWsystems, 12);
DHWInput12_galOil = zeros(numDHWsystems, 12);
DHWInput12_galPropane = zeros(numDHWsystems, 12);

for n = 1:numDHWsystems
    if obj.DHWsystems(n).WaterHeaterType == "GasFiredHeaterWithIndirectTank" || ...
            obj.DHWsystems(n).WaterHeaterType == "GasFiredTank" || ...
            obj.DHWsystems(n).WaterHeaterType == "DemandGas"
        DHWInput12_therms(n, :) = DHWheaterInputEnergy12(n, :) / 100;  % therms gas
    elseif obj.DHWsystems(n).WaterHeaterType == "OilFiredTank" || ...
            obj.DHWsystems(n).WaterHeaterType == "OilFiredHeaterWithIndirectTank"
        DHWInput12_galOil(n, :) = DHWheaterInputEnergy12(n, :) * 1000 ...
            / 139000                    % gallons of heating oil
    elseif obj.DHWsystems(n).WaterHeaterType == "PropaneFiredHeaterWithIndirectTank" || ...
            obj.DHWsystems(n).WaterHeaterType == "PropaneFiredTank"
        DHWInput12_galPropane(n, :) = DHWheaterInputEnergy12(n, :) * 1000 ...
            / 91000                    % gallons of propane
    else DHWInput12_kWh(n, :) = DHWheaterInputEnergy12(n, :) * 1000 ...
            / 3413;    % kWh electricity
    end   % if statement
end  % for loop

% sum the fuel use of each type, monthly and annual
allElectricDHWInput12_kWh = sum(DHWInput12_kWh);

allGasDHWInput12_therms = sum(DHWInput12_therms);

allOilDHWInput12_galOil = sum(DHWInput12_galOil);

allPropaneDHWInput12_galPropane = sum(DHWInput12_galPropane);

% Make a tabel to transmit this information to the building.
% The 1st row is electricity in kWh, 2nd row gas in therms, 3rd row heating
% oil in gallons, 4th row propane in gallons.
fuelArray = [allElectricDHWInput12_kWh; allGasDHWInput12_therms; ...
    allOilDHWInput12_galOil; allPropaneDHWInput12_galPropane];
fuelArray = [fuelArray, sum(fuelArray, 2)];
fuelArray = [fuelArray; [sum(DHWheaterInputEnergy12), allDHWheatersInputAnnual_kBtu]];
DHWfuelType = ["Electricity_kWh", "Gas_therms", "HeatingOil_gallons", ...
    "Propane_gallons", "TotalEnergy_kBtu"]';
DHWfuelTable = array2table(fuelArray, "VariableNames", ...
    {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', ...
    'Oct', 'Nov', 'Dec', 'Annual'});
DHWfuelTable = addvars(DHWfuelTable, DHWfuelType, 'Before', 'Jan');

% The total losses in the system are the usage energy (hot water used at
% fixtures) divided by the input energy. Overall efficiency is 1 - total
% losses. And yes, overall system efficiencies are very low. 40-60% could
% be typical. This includes losses from heaters and piping in mechanical
% rooms, circulation losses, and combustion losses from combustion water
% heaters (if any).
DHWlossFrac = sum(usageEnergyEachFixt12, 'all') / allDHWheatersInputAnnual_kBtu;
DHWsystemEff = 1 - DHWlossFrac;


%% Controls energy

% energy use of the controls or internal pump (separate from energy to heat
% the water)
DHWheaterControls12_kWh = zeros(numDHWsystems, 12);
for n = 1:numDHWsystems
DHWheaterControls12_kWh(n, :) = obj.DHWsystems(n).ControlskW * 8760/12 * ones(1,12);
end   % for loop

DHWtankControls12_kWh = zeros(numDHWtanks, 12);
for n = 1:numDHWtanks
DHWtankControls12_kWh(n, :) = obj.DHWtanks(n).ControlskW * 8760/12 * ones(1,12);
end   % for loop

% all the DHW controls combined for each month, heaters and tanks
allDHWheaterControls12_kWh = sum(DHWheaterControls12_kWh);
allDHWtankControls12_kWh = sum(DHWtankControls12_kWh);
allDHWControls12_kWh = allDHWheaterControls12_kWh + allDHWtankControls12_kWh;
% total annual electricity for DHW controls
allDHWControlsAnnual_kWh = sum(allDHWControls12_kWh);

% Put this in a table. This table is not listed as a building property. It
% could be made available to the user if that is deemed useful.
DHWcontrolsTbl_kWh = array2table([allDHWControls12_kWh allDHWControlsAnnual_kWh], ...
    "VariableNames", {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', ...
    'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Annual'}, "RowNames", {'DHWcontrols_kWh'});

% Add controls electricity to the total electricity consumed by DHW
% systems, in the DHW fuel table. So even if all the water heaters are gas
% or oil fired, there will still be a small amount of electricity use.
DHWfuelTable(1, 2:14) = DHWfuelTable(1, 2:14) + DHWcontrolsTbl_kWh;


%% Internal gains from DHW

%internal gains for use in space heating and cooling calculation
%mechanical and circulation losses for each month multiplied by the
%fraction that goes to conditioned space. all gains are sensible in kBtu.

DHWintGainsMechRoom12  = mechRmLoss12 * mechRmFracCond;

DHWintGainsCircLoss12 = zeros(numDHWsystems, 12);
for n = 1:numDHWsystems
    DHWintGainsCircLoss12(n, :) = circLoss12(n, :) * obj.DHWsystems(n).CircLossesFracCond;
end   % for loop
% internal gains circulation losses for all DHW systems
allDHWintGainsCircLoss12 = sum(DHWintGainsCircLoss12);

% Internal gains from DHW controls (very minor). kBtu
DHWintGainsControls12 = allDHWControls12_kWh * 3413/1000 * mechRmFracCond;

% monthly internal gains for the DHW in the whole building
allDHWintGains12 = DHWintGainsMechRoom12 + allDHWintGainsCircLoss12 + ...
    DHWintGainsControls12 ;

%% Make a table showing all DHW energy flows by month and annual

% construct array with all the numbers, then make it into a table

DHWenergy_kBtu = ["Bathroom Sink"; "Kitchen Sink"; "Shower";...
    "InUnit Dishwasher"; "InUnit Clotheswasher"; "Common Area Clotheswasher"; ...
    "Commercial Kitchen Sink"; "Commercial Dishwasher"; ...
    "Mechanical room pipe/tank losses"; "Circulation losses"; ...
    "Total load"; "DHW heater input"; "Internal gains DHW"];

DHWenergyArray = [usageEnergyEachFixt12; mechRmLoss12; sum(circLoss12); ...
    sum(heaterLoadEnergy12); sum(DHWheaterInputEnergy12); ...
    allDHWintGains12];
DHWenergyArray(:,13) = sum(DHWenergyArray, 2);
DHWenergyTbl = array2table(DHWenergyArray, "VariableNames", ...
    {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', ...
    'Oct', 'Nov', 'Dec', 'Annual'});
DHWenergyTbl = addvars(DHWenergyTbl, DHWenergy_kBtu, 'Before', 'Jan');

%% set needed information tables to building properties

obj.WaterUsageTable = water12Tbl;
obj.DHWenergyUsageTable = DHWenergyTbl;
obj.DHWfuelTable = DHWfuelTable;


end %function

