function DHWSystemArray = ReadSourceData(fileName)
%fileName to provide excel file path for calcInputs file
%   This method will output an array of DHWSystem objects, one per the row

%% Arguments Block
% Set input argument validation.
arguments
    % fileName: Path to excel file containing DHWSystem data.
    fileName (1,1) string
end %argblock

%% Ensure Path Argument Exists
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(fileName);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load DHW  System data. Provided file path" + ...
        " ('" + fileName + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing DHWSystem Data
% Get a list of all sheet names, then filter out DHWSystem one. 
sheetNames = sheetnames(fileName);
DHWSystemMask = contains(sheetNames,"DHWsystems");

% Extract DHWSystem Sheet names and count.
DHWSystemSheetNames = sheetNames(DHWSystemMask);
numDHWSystemSheets = numel(DHWSystemSheetNames);

%% Handle Case: No DHWSystem sheet
% Return early with an empty list of DHWSystem array if there are none to
% import.
if (numDHWSystemSheets == 0)
    % Set to empty array of DHWSystem objects.
    DHWSystemArray = ece.DHWsystem.empty(0,1);
    return;
end %endif


%% Read Data from Sheet in Excel File
% Extract Table and remove empty rows.
DHWSystemTbl = readtable(fileName,"Sheet","DHWsystems", "Range","A2:G16");

% Return empty array if none exist.
emptyCheck = isempty(DHWSystemTbl);
if(emptyCheck)
    DHWSystemArray = ece.DHWsystem.empty(0,1);
    return;
end %endif

%% Iterate through each row to assign properties

% Populate the DHW array with the values in the table.
% determine how many DHW systems the building has (usually only one but allowance for multiple)
NumWaterHeaterSystems = sum(table2array(DHWSystemTbl(DHWSystemTbl.DHWsystemInput == ...
    "FractionBuildingLoadServed", 2:2:end)) > 0);
% create an empty array of water heater objects for as many systems as
% there are in the building
DHWSystemArray = ece.DHWsystem.empty(NumWaterHeaterSystems, 0);

% instantiate the water heater systems from the data table
for WHSysIdx = 1:NumWaterHeaterSystems

       % Create Instance of DHW system class
    % Temporary Slab On grade for allocating data into one object. 
   d = ece.DHWsystem;

   d.WaterHeaterType = table2array(DHWSystemTbl(1,1+2*WHSysIdx));
   d.DHWrecirculation = table2array(DHWSystemTbl(2,2*WHSysIdx));
   d.RecircLoopType = table2array(DHWSystemTbl(3,1+2*WHSysIdx));
   d.ColdWaterMinTempFeb_F = table2array(DHWSystemTbl(4,2*WHSysIdx));
   d.ColdWaterMaxTempAug_F = table2array(DHWSystemTbl(5,2*WHSysIdx));
   d.HeaterOutputTemp_F = table2array(DHWSystemTbl(6,2*WHSysIdx));
   d.HeaterOutputTempCommlKitchen_F = table2array(DHWSystemTbl(7,2*WHSysIdx));
   d.SteadyStateEfficiency = table2array(DHWSystemTbl(8,2*WHSysIdx));
   d.EfficiencySeasonalAmplitude = table2array(DHWSystemTbl(9,2*WHSysIdx));
   d.CircLossesJulyFracOfLoad = table2array(DHWSystemTbl(10,2*WHSysIdx));
   d.CircLossesSeasonalAmplitude = table2array(DHWSystemTbl(11,2*WHSysIdx));
   d.CircLossesFracCond = table2array(DHWSystemTbl(12,2*WHSysIdx));
   d.ControlskW = table2array(DHWSystemTbl(13,2*WHSysIdx));
   d.FractionBuildingLoadServed = table2array(DHWSystemTbl(14,2*WHSysIdx));

    % Store Constructed DHW system Object
    % Place into position in initialized array.
    DHWSystemArray(WHSysIdx) = d;
end % for loop






end  %function end statement