%% Site Setup Example (And also HEA)

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




%% Level 2 calculation- Building modeling


%% input file path and file name
fileName = fullfile(ecetest.testDataRoot,...
    "calcInputs12.xlsx");

%% Full run with summary
bldg = ece.Building();
config = struct('summary', true,'skipCalc',false);
bldg.runModules(fileName, config);

%% Run with no summary
config = struct('summary', false);
bldg = ece.Building();
bldg.runModules(fileName, config);

%% Load Only , no calculations, no summary
% input file path and file name
fileName = fullfile(ecetest.testDataRoot,...
    "calcInputs12.xlsx");
config = struct('skipCalc', false, 'summary', false);
bldg = ece.Building.runModules(fileName, config);


