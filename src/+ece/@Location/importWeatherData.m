function importWeatherData(obj, dataSource)
%IMPORTWEATHERDATA Method to import Weather data as a table.
%   Import a table of weather data from a provided data-source. This table
%   can have 5 columns.

%% Arguments Block
% Enforce input argument specifiers.
% Validate input arguments.
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
    error("Unable to load location Weather data. Provided file path" + ...
        " ('" + excelFilePath + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing Historical Degree Data
% Get a list of all sheet names, then filter out weather data ones. We will
% use the string "WeatherData" to filter out the ones as needed.
sheetNames = sheetnames(dataSource);
weatherMask = contains(sheetNames,"WeatherData");

% Extract WeatherData Sheet names and count.
weatherSheetNames = sheetNames(weatherMask);
numWDSheets = numel(weatherSheetNames);

%% Handle Case: No WeatherData Sheets
% Return early with an empty table for weather data if there was
% no data to import.
if (numWDSheets == 0)
    % Set to empty table.
    obj.WeatherDataTable = table;
    return;
end %endif

%% Import Weather Data from Sheet
% Set up import opts for provided sheet. Assume we only have one sheet for
% now.

% Detect import options.
opts = detectImportOptions(dataSource,...
    "FileType","spreadsheet",...
    "Sheet",weatherSheetNames(1),...
    "Range","A3:E8763");

% Enforce Column Types
opts = setvartype(opts,...
    opts.VariableNames,["datetime","datetime","double","double","double"]);

% Enforce Datetime column formats
opts = setvaropts(opts,...
    "Date","DatetimeFormat","MM/dd/uuuu");
opts = setvaropts(opts,...
    "Time","DatetimeFormat","HH:mm");

% Read Table using Opts and assign to table.
obj.WeatherDataTable = readtable(dataSource,opts);


end %function

