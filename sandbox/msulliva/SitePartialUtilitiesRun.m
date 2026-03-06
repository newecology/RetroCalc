%% Site Partial Utilities Run Example (Setup, HEA, and L2)
% Michael Sullivan
% 5/6/2025

%% Prepare Input Data and Files for HEA
% Use the new schema for test data loading from the test file.
buildingDataPath = fullfile(ecetest.testDataRoot,...
    "singleBuildingInputs.xlsx");
utilityDataPath = fullfile(ecetest.testDataRoot,...
    "partialUtilityInputs.xlsx");
hddDataPath = fullfile(ecetest.testDataRoot,...
    "historicalDDInputs.xlsx");

%% Initialize Site Object
% Set up Site from optional inputs.
site = ece.Site.fromInputExcelFiles(...
    "BuildingPath",buildingDataPath,...
    "UtilityPath",utilityDataPath,...
    "HistDDPath",hddDataPath);

%% KLUDGE: Force Buildings to Exist in Boston to Connect with Solar API
% This should be done more elegantly with a Location class.
for bldgIdx = 1:site.NumBuildings
    % Extract Building
    bldg = site.Buildings(bldgIdx);
    
    % Set Location City/State for API
    bldg.LocationCity = "Boston";
    bldg.LocationState = "MA";
    
    % Map Location to Lat/Long
    bldg.matchCityLocation();

end %forloop

%% Run Processing Routines
% Process each utility and then generate Buildings' corresponding Annual
% and Monthly Usage Tables.
site.computeBuildingUtilityUsages();

%% Compute Building HEAs
% Process each Building's HEA results.
site.computeHEA();

%% Prepare Input Data and Files for Level 2
% Use the schema for loading from a file containing Level2 data for a
% building.
buildingLevel2DataPath = fullfile(ecetest.testDataRoot,...
    "buildingL2Inputs.xlsx");

%% Load L2 Data into Single Building on Site
% Level 2 calculation will be done on one specific building within Site at
% a time.
site.Buildings(1).importLevel2ObjectData(buildingLevel2DataPath);

%% Run Level 2 Calculations
% Selected Building will run Level2 method, which will prepare all relevant
% tables for processing.
site.Buildings(1).computeLevel2();

% Display result to command line.
disp(site.Buildings(1).RunStatsTable);





