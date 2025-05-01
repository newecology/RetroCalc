function heatCoolArray = ReadSourceData(fileName)
% fileName to provide excel file path for calcInputs file
% This method will output an array of HeatCool objects, one per the row

%% Arguments Block
% Set input argument validation.
arguments
    % fileName: Path to excel file containing HeatCool data.
    fileName (1,1) string
end %argblock

%% Ensure Path Argument Exists
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(fileName);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load HeatCool. Provided file path" + ...
        " ('" + fileName + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing heatcool Data
% Get a list of all sheet names, then filter out HeatCool one. 
sheetNames = sheetnames(fileName);
heatCoolMask = contains(sheetNames,"HeatCoolSystems");

% Extract heatCool Sheet names and count.
heatCoolSheetNames = sheetNames(heatCoolMask);
numHeatCoolSheets = numel(heatCoolSheetNames);

%% Handle Case: No HeatCool sheet
% Return early with an empty list of HeatCool array if there are none to
% import.
if (numHeatCoolSheets == 0)
    % Set to empty array of HeatCool objects.
    heatCoolArray = ece.HeatCool.empty(0,1);
    return;
end %endif


%% Read Data from Sheet in Excel File
% Extract Table and remove empty rows.
HeatCoolTbl = readtable(fileName,"Sheet","HeatCoolSystems", "Range","A3:R23");
HeatCoolTbl = rmmissing(HeatCoolTbl,'MinNumMissing',18);

% Get number of Plumbing Fixture from table height, and then preallocate output.
numHeatCool= height(HeatCoolTbl);
heatCoolArray = ece.HeatCool.empty(numHeatCool,0);

% Return empty array if none exist.
emptyCheck = isempty(HeatCoolTbl);
if(emptyCheck)
    heatCoolArray = ece.HeatCool.empty(0,1);
    return;
end %endif

%Converting the relevant data to String and fixing column names
 HeatCoolTbl.SystemName = string(HeatCoolTbl.SystemName); 
 HeatCoolTbl.SystemType = string(HeatCoolTbl.SystemType);
 HeatCoolTbl.SystemFunction = string(HeatCoolTbl.SystemFunction);
 HeatCoolTbl.EnergySource = string(HeatCoolTbl.EnergySource);
 HeatCoolTbl.HeatCapUnits = string(HeatCoolTbl.HeatCapUnits);
 HeatCoolTbl.CoolCapUnits = string(HeatCoolTbl.CoolCapUnits);
 HeatCoolTbl.HeatEffUnits = string(HeatCoolTbl.HeatEffUnits);
 HeatCoolTbl.CoolEffUnits = string(HeatCoolTbl.CoolEffUnits);

% Create an empty array of HeatCool class objects of table row size
HeatCoolArray = ece.HeatCool.empty(height(HeatCoolTbl),0);

% Iterate through each row in the HeatCoolTbl to instantiate an object of 
% the HeatCool class.
for heatCoolIdx = 1:numHeatCool
    % Create Instance of HeatCool
    % Temporary HeatCool for allocating data into one object.
    hc = ece.HeatCool;

    hc.SystemName = HeatCoolTbl.SystemName(heatCoolIdx);
    hc.SystemType = HeatCoolTbl.SystemType(heatCoolIdx);
    hc.SystemFunction = HeatCoolTbl.SystemFunction(heatCoolIdx);
    hc.EnergySource = HeatCoolTbl.EnergySource(heatCoolIdx);
    hc.Quantity = HeatCoolTbl.Quantity(heatCoolIdx);
    hc.HeatCapacityEach = HeatCoolTbl.HeatCapacityEach(heatCoolIdx);
    hc.HeatCapUnits = HeatCoolTbl.HeatCapUnits(heatCoolIdx);
    hc.CoolCapacityEach = HeatCoolTbl.CoolCapacityEach(heatCoolIdx);
    hc.CoolCapUnits = HeatCoolTbl.CoolCapUnits(heatCoolIdx);
    hc.HeatFrac = HeatCoolTbl.HeatFrac(heatCoolIdx);
    hc.CoolFrac = HeatCoolTbl.CoolFrac(heatCoolIdx);
    hc.ControlskW = HeatCoolTbl.ControlskW(heatCoolIdx);
    hc.DistEffHtg = HeatCoolTbl.DistEffHtg(heatCoolIdx);
    hc.DistEffClg = HeatCoolTbl.DistEffClg(heatCoolIdx);
    hc.HeatEff = HeatCoolTbl.HeatEff(heatCoolIdx);
    hc.HeatEffUnits = HeatCoolTbl.HeatEffUnits(heatCoolIdx);
    hc.CoolEff = HeatCoolTbl.CoolEff(heatCoolIdx);
    hc.CoolEffUnits = HeatCoolTbl.CoolEffUnits(heatCoolIdx);

    % Store Constructed heat cool Object
    % Place into position in initialized array.
    heatCoolArray(heatCoolIdx) = hc;


end% end of for loop


end   % function statement






