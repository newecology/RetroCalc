function bldgs = fromBuildingExcelFile(excelFilePath)
%FROMBUILDINGEXCELFILE Method to instantiate Building objects from a
%provided Excel file containing initial building properties.
%   This method will output an array of Building objects, one per the
%   number of sheets in the provided file that contain the name "bldg".

%% Arguments Block
% Set input argument validation.
arguments
    % excelFilePath: Path to excel file containing building data.
    excelFilePath (1,1) string
end %argblock

%% Ensure Path Argument Exists
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(excelFilePath);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load Building data. Provided file path" + ...
        " ('" + excelFilePath + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing Building Data
% Get a list of all sheet names, then filter out Building ones. We will
% use the string "bldg" to filter out the ones as needed.
sheetNames = sheetnames(excelFilePath);
bldgMask = contains(sheetNames,"bldg");

% Extract Building Sheet names and count.
bldgSheetNames = sheetNames(bldgMask);
numBuildingSheets = numel(bldgSheetNames);

%% Handle Case: No Building Objects
% Return early with an empty list of Building objects if there are none to
% import.
if (numBuildingSheets == 0)
    % Set to empty array of Building objects.
    bldgs = ece.Building.empty(0,1);
    return;
end %endif

%% Generate Building Objects
% On a per-sheet basis, open up the corresponding sheet, define input opts,
% and then read in the Building object data to populate a new Building
% object.

% Generate empty array of Building objects to populate.
bldgs = ece.Building.empty(numBuildingSheets,0);

% Iterate through each building sheet
for sheetIdx = 1:numBuildingSheets
    %% Create Instance of Building Object
    % Temporary building for allocating data into one object.
    b = ece.Building;

    %% Read Numeric Properties
    % Read the portion of the Building sheet that provides data to fill in
    % numeric property values.
    % Note: Do not need to include the header row.
    opts = detectImportOptions(excelFilePath,...
        "FileType","spreadsheet",...
        "Sheet",bldgSheetNames(sheetIdx),...
        "Range","B2:B24");

    % Import properties as numeric array to be mapped into corresponding
    % enums, bools, and/or numeric values.
    propArray = readmatrix(excelFilePath,opts);
    b.setNumericPropertiesFromArray(propArray);   

    %% Read String/Enum Building Values
    % Read the portions of the Building sheet that provide values that fill
    % in string or enumeration properties.
    % Note: Since these values are strings, will have to pull in the row
    % above to not treat the first string as a column header name.
    opts = detectImportOptions(excelFilePath,...
        "FileType","spreadsheet",...
        "Sheet",bldgSheetNames(sheetIdx),...
        "Range","B26:B29");

    % Enforce string
    opts = setvartype(opts,"Value","string");

    % Import string properties as array to populate Building object.
    stringPropArray = readmatrix(excelFilePath,opts);
    b.setStringPropertiesFromArray(stringPropArray);

    %% Read Date/Time Building Values
    % Read the portions of the Building sheet that provide values that fill
    % in Datetime properties.
    opts = detectImportOptions(excelFilePath,...
        "FileType","spreadsheet",...
        "Sheet",bldgSheetNames(sheetIdx),...
        "Range","B31:B35");

    % Enforce string
    opts = setvartype(opts,"Value","datetime");

    % Import string properties as array to populate Building object.
    datetimePropArray = readmatrix(excelFilePath,opts);
    b.setDatetimePropertiesFromArray(datetimePropArray);

    %% Store Constructed Building
    % Place into position in initialized array.
    bldgs(sheetIdx) = b;

end %forloop (sheetIdx)


end %function

