function pumpsArr= ReadSourceData(fileName)
% read fan inputs from excel file
%fineName to provide excel file path for calcInputs file
%   This method will output an array of Pump objects, one per the row

%% Arguments Block
% Set input argument validation.
arguments
    % fileName: Path to excel file containing Pump data.
    fileName (1,1) string
end %argblock

%% Ensure Path Argument Exists
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(fileName);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load Pump  data. Provided file path" + ...
        " ('" + fileName + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing Pump Data
% Get a list of all sheet names, then filter out Pump one. 
sheetNames = sheetnames(fileName);
pumpMask = contains(sheetNames,"Pumps");

% Extract Pump Sheet names and count.
pumpSheetNames = sheetNames(pumpMask);
numPumpSheets = numel(pumpSheetNames);

%% Handle Case: No Pump sheet
% Return early with an empty list of Pump array if there are none to
% import.
if (numPumpSheets == 0)
    % Set to empty array of pump objects.
    pumpsArr = ece.Pump.empty(0,1);
    return;
end %endif

%% Read Data from Sheet in Excel File
% Extract Table and remove empty rows.
pumpTbl = readtable(fileName,"Sheet","Pumps", "Range","A3:N13");
pumpTbl = rmmissing(pumpTbl,'DataVariables',{'Quantity','CalcMethod'});

% Get number of movers from table hieght, and then preallocate output.
numPumps = height(pumpTbl);
pumpsArr = ece.Pump.empty(numPumps,0);

% Return empty array if none exist.
emptyCheck = isempty(pumpTbl);
if(emptyCheck)
    pumpsArr = ece.Pump.empty(0,1);
    return;
end %endif

%% Iterate through each row to assign property values
% Populate the pump Array with the values in the table.
for pumpIdx = 1:numPumps
     % Create Instance of pump class
    % Temporary pumpfor allocating data into one object.
    p=ece.Pump;

    % Read Properties  and assigning to respective properties
    p.Name = pumpTbl.Name(pumpIdx);
    p.Quantity = pumpTbl.Quantity(pumpIdx);
    p.MotorHP = pumpTbl.MotorHP(pumpIdx);
    p.FracConditioned = pumpTbl.FracConditioned(pumpIdx);
    p.CalcMethod = pumpTbl.CalcMethod(pumpIdx);
    p.Flow_gpm = pumpTbl.Flow_gpm(pumpIdx);
    p.HeadPressure_feet = pumpTbl.HeadPressure_ft(pumpIdx);
    p.PumpEfficiency = pumpTbl.PumpEff(pumpIdx);
    p.MotorEfficiency = pumpTbl.MotorEff(pumpIdx);
    p.MotorPowerDraw_kW = pumpTbl.MotorPowerDraw_kW(pumpIdx);
    p.AvgSpeed = pumpTbl.AvgSpeed(pumpIdx);
    p.OperationHoursPerDay = pumpTbl.OperationHoursPerDay(pumpIdx);
    p.OperationMonths =[pumpTbl.StartMonth(pumpIdx), pumpTbl.EndMonth(pumpIdx)];

    % Store Constructed PumpObject
    % Place into position in initialized array.
    
    pumpsArr(pumpIdx) = p;
end  % for loop



end % function