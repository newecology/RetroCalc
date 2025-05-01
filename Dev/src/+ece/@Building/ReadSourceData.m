function bldg = ReadSourceData(fileName)

%fileName to provide excel file path for calcInputs file
%   This method will output an array of bldg objects, one per the row

%% Arguments Block
% Set input argument validation.
arguments
    % fileName: Path to excel file containing bldg data.
    fileName (1,1) string
end %argblock

%% Ensure Path Argument Exists
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(fileName);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load building data. Provided file path" + ...
        " ('" + fileName + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing bldg Data
% Get a list of all sheet names, then filter out bldg one. 
sheetNames = sheetnames(fileName);
bldgMask = contains(sheetNames,"bldg");

% Extract bldg Sheet names and count.
bldgSheetNames = sheetNames(bldgMask);
numbldgSheets = numel(bldgSheetNames);

%% Handle Case: No bldg sheet
% Return early with an empty list of bldg array if there are none to
% import.
if (numbldgSheets == 0)
    % Set to empty array of bldg objects.
    bldg = ece.Building.empty(0,1);
    return;
end %endif


%% Read Data from Sheet in Excel File
% Extract Table and remove empty rows.
bldgTbl = readtable(fileName,"Sheet","bldg", "Range","A2:D33");
bldgTbl = rmmissing(bldgTbl,'DataVariables',{'buildingInput'});

% Return empty array if none exist.
emptyCheck = isempty(bldgTbl);
if(emptyCheck)
    bldg = ece.Building.empty(0,1);
    return;
end %endif

%% % Populate the Building properties with the values in the table.
bldg = ece.Building;
bldg.Name = bldgTbl.data(1);
bldg.BldgArea_ft2 = bldgTbl.value(2:4);
bldg.BldgPercentCondAreaCooled = bldgTbl.value(5);
bldg.BldgNumberOfUnits = bldgTbl.value(6);
bldg.BldgNumberOfBedrooms = bldgTbl.value(7:10);
bldg.BldgNumberOfOccupants = bldgTbl.value(11);
bldg.BldgPopulationType = bldgTbl.data(12);
bldg.BldgNumberOfStories = bldgTbl.value(13);
bldg.BldgYearOfConstruction = bldgTbl.value(14);
bldg.ThermalMass = bldgTbl.data(15);
bldg.IntVolume_ft3 = bldgTbl.value(16);
bldg.AirLeakageRate_cfm50perFt2 = bldgTbl.value(17);
bldg.ShieldingClass = bldgTbl.value(18);
bldg.HeatCoolSeasonStartEndDates = datetime(bldgTbl.value(19:22), 'ConvertFrom', 'excel');
bldg.HVACStartEndTimePeriod1 = bldgTbl.value(23:24);
bldg.HeatCoolSetpoints = bldgTbl.value(25:30);
bldg.EnergySourceForDHW = bldgTbl.data(31);

%% Read Degree Days
DDTbl = readtable...
    (fileName,"Sheet","WeatherData","Range",'A3:E8763');
DDTbl.Date = datetime(DDTbl.Date,...
    'InputFormat','MM/dd/yyyy');
DDTbl.Time = datetime(DDTbl.Time,...
    'ConvertFrom','datenum','InputFormat','HH:mm');

bldg.WeatherDataTable = DDTbl;

end  %function end statement