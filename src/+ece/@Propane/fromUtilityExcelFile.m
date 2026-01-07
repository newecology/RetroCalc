function propaneUtilities = fromUtilityExcelFile(excelFilePath)
%FROMUTILITYEXCELFILE Method to instantiate Propane objects from a
%provided Excel file containing elec utility data.
%   This method will output an array of Propane objects, one per the
%   number of sheets in the provided file that contain the name "Propane".

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
    error("Unable to load Propane Utility data. Provided file path" + ...
        " ('" + excelFilePath + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing Propane Utility Data
% Get a list of all sheet names, then filter out Propane ones. We will
% use the string "Propane" to filter out the ones as needed.
sheetNames = sheetnames(excelFilePath);
PropaneMask = contains(sheetNames,"propane");

% Extract Propane utility Sheet names and count.
PropaneSheetNames = sheetNames(PropaneMask);
numPropaneSheets = numel(PropaneSheetNames);

%% Handle Case: No Propane Utilities
% Return early with an empty list of Propane utilities if there are none to
% import.
if (numPropaneSheets == 0)
    % Set to empty array of Propane objects.
    propaneUtilities = ece.Propane.empty(0,1);
    return;
end %endif

%% Generate Propane Utilities
% On a per-sheet basis, open up the corresponding sheet, define input opts,
% and then read in the Propane utility data to populate a new
% Propane Utility object.

% Generate empty array of Propane Utilities to populate.
propaneUtilities = ece.Propane.empty(numPropaneSheets,0);

% Iterate through each sheet
for sheetIdx = 1:numPropaneSheets
    %% Create Instance of Propane Utility
    % Temporary Propane utility for allocating data into one object.
    propaneUtil = ece.Propane;

    %% Read Properties
    % Read the portion of the Propane Utility sheet that provides the
    % flags for the corresponding properties.
    opts = detectImportOptions(excelFilePath,...
        "FileType","spreadsheet",...
        "Sheet",PropaneSheetNames(sheetIdx),...
        "Range","B1:B10");

    % Import properties as numeric array to be mapped into corresponding
    % enums, bools, and values.
    propArray = readmatrix(excelFilePath,opts);
    propaneUtil.setFlagPropertiesFromArray(propArray);   


    %% Read Usage Table
    % Read the portion of the Propane Utility sheet that provides the
    % usage table values for however many months are entered.
    opts = detectImportOptions(excelFilePath,...
        "FileType","spreadsheet",...
        "Sheet",PropaneSheetNames(sheetIdx),...
        "Range","A12:D48");

    % Import usage table as table into Propane object.
    rawUsageTable = readtable(excelFilePath,opts);
    propaneUtil.importUsageTable(rawUsageTable);

    %% Store Constructed Propane Object
    % Place into position in initialized array.
    propaneUtilities(sheetIdx) = propaneUtil;

end %forloop (sheetIdx)


end %function

