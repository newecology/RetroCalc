function elecUtils = fromUtilityExcelFile(excelFilePath)
%FROMUTILITYEXCELFILE Method to instantiate Electricity objects from a
%provided Excel file containing elec utility data.
%   This method will output an array of Electricity objects, one per the
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
    error("Unable to load Electricity Utility data. Provided file path" + ...
        " ('" + excelFilePath + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing Electricity Utility Data
% Get a list of all sheet names, then filter out Electricity ones. We will
% use the string "elec" to filter out the ones as needed.
sheetNames = sheetnames(excelFilePath);
elecMask = contains(sheetNames,"elec");

% Extract Elec utility Sheet names and count.
elecSheetNames = sheetNames(elecMask);
numElecSheets = numel(elecSheetNames);

%% Handle Case: No Elec Utilities
% Return early with an empty list of Elec utilities if there are none to
% import.
if (numElecSheets == 0)
    % Set to empty array of Electricity objects.
    elecUtils = ece.Electricity.empty(0,1);
    return;
end %endif

%% Generate Electricity Utilities
% On a per-sheet basis, open up the corresponding sheet, define input opts,
% and then read in the Electricity utility data to populate a new
% Electricity Utility object.

% Generate empty array of Electricity Utilities to populate.
elecUtils = ece.Electricity.empty(numElecSheets,0);

% Iterate through each sheet
for sheetIdx = 1:numElecSheets
    %% Create Instance of Electricity Utility
    % Temporary electric utility for allocating data into one object.
    e = ece.Electricity;

    %% Read Properties
    % Read the portion of the Electricity Utility sheet that provides the
    % flags for the corresponding properties.
    opts = detectImportOptions(excelFilePath,...
        "FileType","spreadsheet",...
        "Sheet",elecSheetNames(sheetIdx),...
        "Range","B1:B11");

    % Import properties as numeric array to be mapped into corresponding
    % enums, bools, and values.
    propArray = readmatrix(excelFilePath,opts);
    e.setFlagPropertiesFromArray(propArray);   


    %% Read Usage Table
    % Read the portion of the Electricity Utility sheet that provides the
    % usage table values for however many months are entered.
    opts = detectImportOptions(excelFilePath,...
        "FileType","spreadsheet",...
        "Sheet",elecSheetNames(sheetIdx),...
        "Range","A13:D49");

    % Import usage table as table into electricity object.
    rawUsageTable = readtable(excelFilePath,opts);
    e.importUsageTable(rawUsageTable);

    %% Read Fractional Limits
    % Read the portion of the Electricity Utility sheet that provides the
    % fractional Heating/Cooling values.
    opts = detectImportOptions(excelFilePath,...
        "FileType","spreadsheet",...
        "Sheet",elecSheetNames(sheetIdx),...
        "Range","A52:C64");

    % Ensure Month Column is string-typed.
    opts = setvartype(opts,"Month","string");

    % Import Fraction Table as table into electricity object.
    e.HeatFractionLimitsTable = readtable(excelFilePath,opts);

    %% Store Constructed Electricity Object
    % Place into position in initialized array.
    elecUtils(sheetIdx) = e;

end %forloop (sheetIdx)


end %function

