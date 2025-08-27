%% Site Full Run Example (Setup, HEA, and L2)
% Michael Sullivan
% 5/6/2025

%% Prepare Input Data and Files for HEA
% Use the new schema for test data loading from the test file.
buildingDataPath = fullfile(ecetest.testDataRoot,...
    "buildingInputs.xlsx");
utilityDataPath = fullfile(ecetest.testDataRoot,...
    "utilityInputs.xlsx");
hddDataPath = fullfile(ecetest.testDataRoot,...
    "historicalDDInputs.xlsx");
weatherDataPath = fullfile(ecetest.testDataRoot,...
    "weatherDataInputs.xlsx");

%% Initialize Site Object
% Set up Site from optional inputs.
site = ece.Site.fromInputExcelFiles(...
    "BuildingPath",buildingDataPath,...
    "UtilityPath",utilityDataPath,...
    "HistDDPath",hddDataPath,...
    "WeatherDataPath",weatherDataPath);

%% Run Processing Routines4
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





