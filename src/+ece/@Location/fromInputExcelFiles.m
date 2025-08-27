function location = fromInputExcelFiles(fOpts)
%FROMINPUTEXCELFILES Method to create Location object from a set of input EXCEL
%files.
%  Location object can be generated from a variety of input files, so this is a
%   method that organizes all the possible inputs into a single place and
%   splits to the corresponding properties the file informs.

%% Arguments Block
% Set up optional arguments.
arguments
    % fOpts: File opts, optional input paths to load from.
    % Location: String path to EXCEL file containing Location info.
    fOpts.LocationPath (:,1) string = string.empty(0,1);

      % HistDDPath: String path to EXCEL file containing historical degree
    % day data.
    fOpts.HistDDPath (:,1) string = string.empty(0,1);

    % weather data path: String path to EXCEL file containing weatherr data
    fOpts.weatherPath (:,1) string = string.empty(0,1);


end %argblock

%% Initialize Location Object
% Default instantiation, independent of any input arguments.
location = ece.Location;

%% Optional: Set up Site Location
% Process optional input Location.
if ~isempty(fOpts.LocationPath)
    location.importLocation(fOpts.LocationPath);
end %endif


%% Optional: Set up Site Historical DegreeDays
% Process optional Historical Degree Days file into Site.
if ~isempty(fOpts.HistDDPath)
    location.importHistoricalDDTables(fOpts.HistDDPath);
end %endif

%% Optional: Set up Site weather Data
% Process optional weather data file into Site.
if ~isempty(fOpts.weatherPath)
    location.importWeatherData(fOpts.weatherPath);
end %endif


end %function

