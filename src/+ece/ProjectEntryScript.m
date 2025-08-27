% --- Project Entry Script
% Note: Used to test code that has been created.
%% -- Create a Building
% Initialize as default.
testBuilding = ece.Building;

% input file path and file name
fileName = fullfile(ecetest.testDataRoot,...
    "calcInputs12.xlsx");

%% Building
testBuilding = ece.Building.readSourceData(fileName);

%% Set building location

% Knowing city and state, latitude and longitude are fetched from data table
testBuilding.LocationCity = "Boston";
testBuilding.LocationState = "MA";
testBuilding.matchCityLocation;

%% Pumps
% read pump data from excel file as a table 
testBuilding.Pumps = ece.Pump.readSourceData(fileName);


%% Make Glazing
% Read glazing data from input source
testBuilding.GlazedSurfaces = ece.Glazing.readSourceData(fileName);

%% Determine solar gains for each facade
testBuilding.calcSolarGains();

%% Make Opaque Surfaces

testBuilding.OpaqueSurfaces = ece.OpaqueSurface.readSourceData(fileName);


%% Slab on Grade
% Initialize a slab on grade
% read slab on grade data from excel file as a table 

testBuilding.SlabOnGrade = ece.SlabOnGrade.readSourceData(fileName);

%% Below Grade Surfaces
% Initialize below grade surfaces
% Read below grade surfaces data from excel file as a table as well as soil
testBuilding.BelowGradeSurfaces = ece.BelowGradeSurface.readSourceData(fileName);

%%  space types

testBuilding.Spaces = ece.Space.readSourceData(fileName);

%% DHW
% read the data for all DHW system
% push the instances of water heater systems into the DHW system class
testBuilding.DHWsystems = ece.DHWsystem.readSourceData(fileName);

%%
% Enter the hot water tanks associated with DHW

testBuilding.DHWtanks = ece.DHWtanks.readSourceData(fileName);

%%
% repeat for the pipes in the mechanical room

testBuilding.DHWpipesMechRoom = ece.DHWpipesMechRoom.readSourceData(fileName);
%%
% read plumbing fixture data and eliminate empty rows from table

testBuilding.PlumbingFixtures = ece.PlumbingFixture.readSourceData(fileName);
%% 
% calculate water usage for each fixture type for each month
% as well as water heating energy for hot water using fixtures, each month
testBuilding.calculateWaterDHW();
disp("Monthly water usage for each type of plumbing fixture or appliance")
disp("Includes water used for irrigation and cooling towers")
testBuilding.WaterUsageTable
testBuilding.DHWenergyUsageTable
testBuilding.DHWfuelTable

%% Appliances

% read appliances that are in the building and eliminate empty rows from table

testBuilding.Appliances = ece.Appliance.readSourceData(fileName);

%% Calculate appliance energy use and internal gains

% Calculate the gas, electricity, and internal gains of each appliance
% and display results
 testBuilding.calculateApplianceElectricAndGasUse()
 disp("Appliance energy usage by appliance type")
 testBuilding.ApplianceResultsTable

 % the appliance results array is a 4x12 matrix for 12 months
 % row 1 gas therms, row 2 electric kWh, row 3 internal sensible gains
 % kBtu, row 4 internal latent gains kBtu
 % for all appliances combined
 disp("Appliance monthly energy table")
 testBuilding.ApplianceEnergyTable12

%% calculate shell area of building 
% calculate the six sided shell area of the building for use in air leakage 
% metrics which use cfm50/ft2 of shell
% testBuilding.calculateEnvelopeArea;

%% Degree days


% calculate degree days and average weather conditions
testBuilding.calcDegreeDays();

% weather array for use in calculations. 24 columns for time 1 and time 2 in 
% each month (Jan day, Jan night, Feb day, Feb night, etc.)
% 3 rows for HDD, CDD, enthalpy days and 3 rows for avg temp degrees F, 
% avg enthalpy in Btu/lb mass dry air, and average wind speed in mph
% disp("Weather array. Columns are Jan day, Jan night, Feb day, etc. ") 
% disp("rows are HDD, CDD, enthalpy days, average temp, average")
% disp("enthalpy in Btu/lb mass dry air, and average wind speed in mph") 
% testBuilding.weatherMonthly
% 
% weather table for user to view and check
% this is the same weather data parsed differently
% negatives are excluded for heating degree days but are included for
% cooling degree and enthalpy days
% testBuilding.DegreeDaysTable

%% Airmovers: fans and Ventilation

testBuilding.Airmovers = ece.Airmovers.readSourceData(fileName);


%% calculate monthly average ventilation air flows for time periods 1 and 2
testBuilding.calcMonthlyVentilation();


%% Internal Gains
testBuilding.calcInternalGainsAndElec();
%testBuilding.ElectricUsageTable
testBuilding.InternalGainsTable
disp("Internal Gains Array. Columns are Jan day, Jan night, Feb day, etc.")
disp("Rows are 1 sensible, 2 sens and latent, 3 latent, all in kBtu")
testBuilding.InternalGainsArray_kBtu


%% heat/cool systems

testBuilding.HeatCool = ece.HeatCool.readSourceData(fileName);
testBuilding.calcSpaceHeatingEnergy()
testBuilding.SpaceHeatingTable_kBtu
testBuilding.HeatFuelTable
testBuilding.calcSpaceCoolingEnergy()
testBuilding.SpaceCoolingTable_kBtu
testBuilding.SpaceCoolingTable_kWh

%% 
% Fill missing entries in electric usage table for space heating and cooling, 
% and update the totals row.
testBuilding.ElectricUsageTable(testBuilding.ElectricUsageTable.electricLoadskWh ...
    == "space heating", 2:14) = testBuilding.HeatFuelTable(1, 2:14);

testBuilding.ElectricUsageTable(testBuilding.ElectricUsageTable.electricLoadskWh ...
    == "space cooling", 2:14) = testBuilding.SpaceCoolingTable_kWh(5, 4:16);

testBuilding.ElectricUsageTable(end, 2:14) = ...
    sum(testBuilding.ElectricUsageTable(1:end-1, 2:14)); 

testBuilding.ElectricUsageTable

%% Total building energy use by month
testBuilding.calcEnergyUsage();
testBuilding.BuildingEnergyUsageTable

