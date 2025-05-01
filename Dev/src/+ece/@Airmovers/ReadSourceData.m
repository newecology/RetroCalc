function airMoversArr = ReadSourceData(fileName)
%fineName to provide excel file path for calcInputs file
%   This method will output an array of Airmovers objects, one per the row

%% Arguments Block
% Set input argument validation.
arguments
    % fileName: Path to excel file containing Airmovers data.
    fileName (1,1) string
end %argblock

%% Ensure Path Argument Exists
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(fileName);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load Airmovers  data. Provided file path" + ...
        " ('" + fileName + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing Airmovers Data
% Get a list of all sheet names, then filter out Airmovers one. 
sheetNames = sheetnames(fileName);
AMMask = contains(sheetNames,"AirMovers");

% Extract AM Sheet names and count.
AMSheetNames = sheetNames(AMMask);
numAMSheets = numel(AMSheetNames);

%% Handle Case: No Airmover sheet
% Return early with an empty list of Airmovers array if there are none to
% import.
if (numAMSheets == 0)
    % Set to empty array of Airmover objects.
    airMoversArr = ece.Airmovers.empty(0,1);
    return;
end %endif


%% Read Data from Sheet in Excel File
% Extract Table and remove empty rows.
AirmoversTbl = readtable(fileName,"Sheet","AirMovers", "Range","A2:T18");
AirmoversTbl = rmmissing(AirmoversTbl,'MinNumMissing', 19);

% Get number of movers from table hieght, and then preallocate output.
numAirmovers = height(AirmoversTbl);
airMoversArr = ece.Airmovers.empty(numAirmovers,0);

% Return empty array if none exist.
emptyCheck = isempty(AirmoversTbl);
if(emptyCheck)
    airMoversArr = ece.Airmovers.empty(0,1);
    return;
end %endif

%% Iterate through each row
for amIdx = 1:numAirmovers
    % Create Instance of Airmovers class
    % Temporary Airmovers for allocating data into one object.
    a = ece.Airmovers;

    % Read Properties  and assigning to respective properties
    a.Name = AirmoversTbl.Name(amIdx);
    a.Type = AirmoversTbl.Type(amIdx);
    a.Quantity = AirmoversTbl.Quantity(amIdx);
    a.DesignCFMperUnit = AirmoversTbl.DesignCFMperUnit(amIdx);
    a.FractionVentilation = AirmoversTbl.FractionVentilation(amIdx);
    a.AverageSpeed = [AirmoversTbl.AverageSpeedTime1(amIdx), ...
        AirmoversTbl.AverageSpeedTime2(amIdx)];
    a.OperationHoursPerDay = [AirmoversTbl.Hours1PerDay(amIdx), ...
        AirmoversTbl.Hours2PerDay(amIdx)];
    a.HeatingSensibleEfficiency = AirmoversTbl.HeatingSensibleEfficiency(amIdx);
    a.CoolingTotalEfficiency = AirmoversTbl.CoolingTotalEfficiency(amIdx);
    a.MotorHP = AirmoversTbl.MotorHP(amIdx);
    a.FractionConditioned = AirmoversTbl.FractionConditioned(amIdx);
    a.CalcMethod = AirmoversTbl.CalcMethod(amIdx);
    a.TotalStaticPressure_inch = AirmoversTbl.TotalStaticPressure_inch(amIdx);
    a.FanEfficiency = AirmoversTbl.FanEfficiency(amIdx);
    a.MotorEfficiency = AirmoversTbl.MotorEfficiency(amIdx);
    a.MotorPowerDraw_kW = AirmoversTbl.MotorPowerDraw_kW(amIdx);
    a.OperationMonths = [AirmoversTbl.StartMonth(amIdx), AirmoversTbl.EndMonth(amIdx)];
    
    % Store Constructed Airmovers Object
    % Place into position in initialized array.
    
    airMoversArr(amIdx) = a;

end %forloop (amIdx)


end %function
