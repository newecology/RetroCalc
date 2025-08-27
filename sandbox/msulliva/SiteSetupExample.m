%% Site Setup Example (And also HEA)
% Michael Sullivan
% 3/4/2025

%% Prepare Input Data and Files
% Use the new schema for test data loading from the test file.
buildingDataPath = fullfile(ecetest.testDataRoot,...
    "buildingInputs.xlsx");
utilityDataPath = fullfile(ecetest.testDataRoot,...
    "utilityInputs.xlsx");
hddDataPath = fullfile(ecetest.testDataRoot,...
    "historicalDDInputs.xlsx");

%% Initialize Site Object
% Set up Site from optional inputs.
site = ece.Site.fromInputExcelFiles(...
    "BuildingPath",buildingDataPath,...
    "UtilityPath",utilityDataPath,...
    "HistDDPath",hddDataPath);

%% Run Processing Routines
% Process each utility and then generate Buildings' corresponding Annual
% and Monthly Usage Tables.
site.computeBuildingUtilityUsages();

%% Compute Building HEAs
% Process each Building's HEA results.
site.computeHEA();


%% Assumptions to Check
% Site HEA
%   Is this the sum of all Building HEAs? Yeah, we think so.
%
% Irrigation (and Cooling Tower)
%   Need to add code for importing the amount of gallons used for Cooling
%   and Irrigation. Some irrigation meters are entirely separated, and are
%   just flagged as Irrigation. Generate a message: "We have not estimated
%   an Irrigation amount. Deal within L2 Analysis".



