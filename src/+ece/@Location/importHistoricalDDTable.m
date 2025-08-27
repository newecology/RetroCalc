function importHistoricalDDTable(obj, dataSource)
%IMPORTHISTORICALDEGREEDAYS Method to import historical degree data as a
%table.
%   Import a three-column table of historical degree day data into Site
%   that has date, HDD, and CDD information.

%% Arguments Block
% Enforce input argument specifiers and validate input arguments.
arguments
    % obj: Self-referential Location object.
    obj (1,1) ece.Location

    % dataSource: Input data source that contains the degree day
    % information.
    dataSource (1,1) string

end %argblock

%% Ensure Path Argument Exists
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(dataSource);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load site HistDD data. Provided file path" + ...
        " ('" + excelFilePath + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing Historical Degree Data
% Get a list of all sheet names, then filter out histDD ones. We will
% use the string "histDD" to filter out the ones as needed.
sheetNames = sheetnames(dataSource);
hddMask = contains(sheetNames,"histDD");

% Extract HistDD Sheet names and count.
hddSheetNames = sheetNames(hddMask);
numHDDSheets = numel(hddSheetNames);

%% Handle Case: No HistDD Sheets
% Return early with an empty table for historical degree days if there was
% no data to import.
if (numHDDSheets == 0)
    % Set to empty table.
    obj.HistoricalDDTable = table;
    return;
end %endif

%% Import Historical Data from Sheet
% Set up import opts for provided sheet. Assume we only have one sheet for
% now.

% Detect import options.
opts = detectImportOptions(dataSource,...
    "FileType","spreadsheet",...
    "Sheet",hddSheetNames(1));

% Enforce Column Types
opts = setvartype(opts,...
    opts.VariableNames,["datetime","double","double"]);

% Read Table using Opts
obj.HistoricalDDTable = readtable(dataSource,opts);

end %function

