% input file path and file name
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


