function gasUtils = fromUtilityExcelFile(excelFilePath)
%FROMUTILITYEXCELFILE Method to instantiate Gas objects from a
%provided Excel file containing elec utility data.
%   This method will output an array of Gas objects, one per the
%   number of sheets in the provided file that contain the name "gas".

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
    error("Unable to load Gas Utility data. Provided file path" + ...
        " ('" + excelFilePath + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing Gas Utility Data
% Get a list of all sheet names, then filter out Gas ones. We will
% use the string "gas" to filter out the ones as needed.
sheetNames = sheetnames(excelFilePath);
gasMask = contains(sheetNames,"gas");

% Extract Gas utility Sheet names and count.
gasSheetNames = sheetNames(gasMask);
numGasSheets = numel(gasSheetNames);

%% Handle Case: No Gas Utilities
% Return early with an empty list of Gas utilities if there are none to
% import.
if (numGasSheets == 0)
    % Set to empty array of Gas objects.
    gasUtils = ece.Gas.empty(0,1);
    return;
end %endif

%% Generate Gas Utilities
% On a per-sheet basis, open up the corresponding sheet, define input opts,
% and then read in the Gas utility data to populate a new
% Gas Utility object.

% Generate empty array of Gas Utilities to populate.
gasUtils = ece.Gas.empty(numGasSheets,0);

% Iterate through each sheet
for sheetIdx = 1:numGasSheets
    %% Create Instance of Gas Utility
    % Temporary gas utility for allocating data into one object.
    g = ece.Gas;

    %% Read Properties
    % Read the portion of the Gas Utility sheet that provides the
    % flags for the corresponding properties.
    opts = detectImportOptions(excelFilePath,...
        "FileType","spreadsheet",...
        "Sheet",gasSheetNames(sheetIdx),...
        "Range","B1:B9");

    % Import properties as numeric array to be mapped into corresponding
    % enums, bools, and values.
    propArray = readmatrix(excelFilePath,opts);
    g.setFlagPropertiesFromArray(propArray);   


    %% Read Usage Table
    % Read the portion of the Gas Utility sheet that provides the
    % usage table values for however many months are entered.
    opts = detectImportOptions(excelFilePath,...
        "FileType","spreadsheet",...
        "Sheet",gasSheetNames(sheetIdx),...
        "Range","A11:D47");

    % Import usage table as table into gas object.
    rawUsageTable = readtable(excelFilePath,opts);
    g.importUsageTable(rawUsageTable);

    %% Store Constructed Gas Object
    % Place into position in initialized array.
    gasUtils(sheetIdx) = g;

end %forloop (sheetIdx)


end %function

