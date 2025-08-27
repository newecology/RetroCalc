function oilUtilities = fromUtilityExcelFile(excelFilePath)
%FROMUTILITYEXCELFILE Method to instantiate Oil objects from a
%provided Excel file containing elec utility data.
%   This method will output an array of Oil objects, one per the
%   number of sheets in the provided file that contain the name "Oil".

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
    error("Unable to load Oil Utility data. Provided file path" + ...
        " ('" + excelFilePath + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing Oil Utility Data
% Get a list of all sheet names, then filter out Oil ones. We will
% use the string "Oil" to filter out the ones as needed.
sheetNames = sheetnames(excelFilePath);
OilMask = contains(sheetNames,"oil");

% Extract Oil utility Sheet names and count.
OilSheetNames = sheetNames(OilMask);
numOilSheets = numel(OilSheetNames);

%% Handle Case: No Oil Utilities
% Return early with an empty list of Oil utilities if there are none to
% import.
if (numOilSheets == 0)
    % Set to empty array of Oil objects.
    oilUtilities = ece.Oil.empty(0,1);
    return;
end %endif

%% Generate Oil Utilities
% On a per-sheet basis, open up the corresponding sheet, define input opts,
% and then read in the Oil utility data to populate a new
% Oil Utility object.

% Generate empty array of Oil Utilities to populate.
oilUtilities = ece.Oil.empty(numOilSheets,0);

% Iterate through each sheet
for sheetIdx = 1:numOilSheets
    %% Create Instance of Oil Utility
    % Temporary Oil utility for allocating data into one object.
    oilUtil = ece.Oil;

    %% Read Properties
    % Read the portion of the Oil Utility sheet that provides the
    % flags for the corresponding properties.
    opts = detectImportOptions(excelFilePath,...
        "FileType","spreadsheet",...
        "Sheet",OilSheetNames(sheetIdx),...
        "Range","B1:B7");

    % Import properties as numeric array to be mapped into corresponding
    % enums, bools, and values.
    propArray = readmatrix(excelFilePath,opts);
    oilUtil.setFlagPropertiesFromArray(propArray);   


    %% Read Usage Table
    % Read the portion of the Oil Utility sheet that provides the
    % usage table values for however many months are entered.
    opts = detectImportOptions(excelFilePath,...
        "FileType","spreadsheet",...
        "Sheet",OilSheetNames(sheetIdx),...
        "Range","A9:D45");

    % Import usage table as table into Oil object.
    rawUsageTable = readtable(excelFilePath,opts);
    oilUtil.importUsageTable(rawUsageTable);

    %% Store Constructed Oil Object
    % Place into position in initialized array.
    oilUtilities(sheetIdx) = oilUtil;

end %forloop (sheetIdx)


end %function

