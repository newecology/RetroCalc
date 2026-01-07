function importSiteInputsData(site, dataSource)
%IMPORTHISTORICALDEGREEDAYS Method to import historical degree data as a
%table.
%   Import a three-column table of historical degree day data.

%% Arguments Block
% Enforce input argument specifiers.
% Validate input arguments.
arguments
    % site: Self-referential Site object.
    site (1,1) ece.Site

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
    error("Unable to load site Site Input data. Provided file path" + ...
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

%% Import Site inputs strings
% Set up import opts for provided sheet. Assume we only have one sheet for
% now.

% Detect import options.
opts = detectImportOptions(dataSource,...
    "FileType","spreadsheet",...
    "Sheet",locSheetNames(1),...
    "Range","A1:B4");
opts = setvartype(opts, 'Value', 'string');

% Read Table using Opts

siteTable = readtable(dataSource,opts);
site.Name = siteTable.Value(1);
site.Location.City = siteTable.Value(2);
site.Location.State = siteTable.Value(3);



%% Import Site inputs numerical
% Set up import opts for provided sheet. Assume we only have one sheet for
% now.

% Detect import options.
opts = detectImportOptions(dataSource,...
    "FileType","spreadsheet",...
    "Sheet",locSheetNames(1),...
    "Range","A1:B10");

%opts = setvartype(opts, 'Value', 'string');

% Read Table using Opts

siteTable = readtable(dataSource,opts);
site.Location.Latitude = double(siteTable.Value(1));
site.Location.Longitude = double(siteTable.Value(2));
site.CarbonEqValueElectricity_kgPerkWh = double(siteTable.Value(3));
site.CarbonEqValueGas_kgPerTherm = double(siteTable.Value(4));
site.CarbonEqValueOil_kgPerGallon = double(siteTable.Value(5));
site.CarbonEqValuePropane_kgPerGallon = double(siteTable.Value(6));


end %function

