function importLocation(location, dataSource)
%IMPORTHISTORICALDEGREEDAYS Method to import historical degree data as a
%table.
%   Import a three-column table of historical degree day data.

%% Arguments Block
% Enforce input argument specifiers.
% Validate input arguments.
arguments
    % site: Self-referential Site object.
    location (1,1) ece.Location

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
    error("Unable to load site Location data. Provided file path" + ...
        " ('" + excelFilePath + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing Location
% Get a list of all sheet names, then filter out histDD ones. We will
% 
sheetNames = sheetnames(dataSource);
locMask = contains(sheetNames,"Site");

% Extract HistDD Sheet names and count.
locSheetNames = sheetNames(locMask);




%% Import Historical Data from Sheet
% Set up import opts for provided sheet. Assume we only have one sheet for
% now.

% Detect import options.
opts = detectImportOptions(dataSource,...
    "FileType","spreadsheet",...
    "Sheet",locSheetNames(1),...
    "Range","A1:D2");

% Enforce Column Types
opts = setvartype(opts,...
    opts.VariableNames,["string","string","double","double"]);

% Read Table using Opts
locTable = readtable(dataSource,opts);
location.City = locTable.City(1);
location.State = locTable.State(1);
location.Lat = locTable.Lat(1);
location.Lon = locTable.Lon(1);


end %function

