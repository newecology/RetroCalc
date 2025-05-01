function waterUtils = fromUtilityExcelFile(excelFilePath)
%FROMUTILITYEXCELFILE Method to instantiate Water objects from a
%provided Excel file containing elec utility data.
%   This method will output an array of Water objects, one per the
%   number of sheets in the provided file that contain the name "elec".

%% Arguments Block
% Set input argument validation.
arguments
    % excelFilePath: Path to excel file containing utility data.
    excelFilePath (1,1) string
end %argblock

%% Ensure Path Argument Exists
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(excelFilePath);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load Water Utility data. Provided file path" + ...
        " ('" + excelFilePath + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing Water Utility Data
% Get a list of all sheet names, then filter out Water ones. We will
% use the string "water" to filter out the ones as needed.
sheetNames = sheetnames(excelFilePath);
waterMask = contains(sheetNames,"water");

% Extract Water utility Sheet names and count.
waterSheetNames = sheetNames(waterMask);
numWaterSheets = numel(waterSheetNames);

%% Handle Case: No Water Utilities
% Return early with an empty list of Water utilities if there are none to
% import.
if (numWaterSheets == 0)
    % Set to empty array of Water objects.
    waterUtils = ece.Water.empty(0,1);
    return;
end %endif

%% Generate Water Utilities
% On a per-sheet basis, open up the corresponding sheet, define input opts,
% and then read in the Water utility data to populate a new Water Utility 
% object.

% Generate empty array of Water Utilities to populate.
waterUtils = ece.Water.empty(numWaterSheets,0);

% Iterate through each sheet
for sheetIdx = 1:numWaterSheets
    %% Create Instance of Water Utility
    % Temporary water utility for allocating data into one object.
    w = ece.Water;

    %% Read Properties
    % Read the portion of the Water Utility sheet that provides the
    % flags for the corresponding properties.
    opts = detectImportOptions(excelFilePath,...
        "FileType","spreadsheet",...
        "Sheet",waterSheetNames(sheetIdx),...
        "Range","B1:B6");

    % Import properties as numeric array to be mapped into corresponding
    % enums, bools, and values.
    propArray = readmatrix(excelFilePath,opts);
    w.setFlagPropertiesFromArray(propArray);   


    %% Read Usage Table
    % Read the portion of the Water Utility sheet that provides the
    % usage table values for however many months are entered.
    opts = detectImportOptions(excelFilePath,...
        "FileType","spreadsheet",...
        "Sheet",waterSheetNames(sheetIdx),...
        "Range","A8:D44");

    % Import usage table as table into water object.
    rawUsageTable = readtable(excelFilePath,opts);
    w.importUsageTable(rawUsageTable);

    %% Store Constructed Water Object
    % Place into position in initialized array.
    waterUtils(sheetIdx) = w;

end %forloop (sheetIdx)


end %function

