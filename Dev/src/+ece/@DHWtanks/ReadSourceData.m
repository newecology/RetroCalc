function dhwTankArray = ReadSourceData(fileName)
%fileName to provide excel file path for calcInputs file
%   This method will output an array of dhwTank objects, one per the row

%% Arguments Block
% Set input argument validation.
arguments
    % fileName: Path to excel file containing dhwTank data.
    fileName (1,1) string
end %argblock

%% Ensure Path Argument Exists
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(fileName);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load DHW Tanks data. Provided file path" + ...
        " ('" + fileName + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing dhwTank Data
% Get a list of all sheet names, then filter out dhwTank one. 
sheetNames = sheetnames(fileName);
dhwTankMask = contains(sheetNames,"DHWtanksPipes");

% Extract dhwTank Sheet names and count.
dhwTankSheetNames = sheetNames(dhwTankMask);
numdhwTankSheets = numel(dhwTankSheetNames);

%% Handle Case: No dhwTank sheet
% Return early with an empty list of dhwTank array if there are none to
% import.
if (numdhwTankSheets == 0)
    % Set to empty array of dhwTank objects.
    dhwTankArray = ece.DHWtanks.empty(0,1);
    return;
end %endif


%% Read Data from Sheet in Excel File
% Extract Table and remove empty rows.
dhwTankTbl = readtable(fileName,"Sheet","DHWtanksPipes", "Range","A2:I6");
dhwTankTbl = rmmissing(dhwTankTbl,'DataVariables',{'TankName'});

% Get number of opaque surfacesfrom table height, and then preallocate output.
numdhwTank = height(dhwTankTbl);
dhwTankArray = ece.DHWtanks.empty(numdhwTank,0);

% Return empty array if none exist.
emptyCheck = isempty(dhwTankTbl);
if(emptyCheck)
    dhwTankArray = ece.DHWtanks.empty(0,1);
    return;
end %endif

%% Iterate through each row to assign properties

% Populate the slab on grade array with the values in the table.


for tankIDx = 1:numdhwTank
      % Create Instance of Slab On grade class
    % Temporary Slab On grade for allocating data into one object.
    dt=ece.DHWtanks;

   dt.TankName = dhwTankTbl.TankName(tankIDx);
   dt.Quantity = dhwTankTbl.Quantity(tankIDx);
   dt.Volume_gal = dhwTankTbl.Volume_gal(tankIDx);
   dt.TankTemp_F = dhwTankTbl.TankTemp_F(tankIDx);
   dt.RefTemp_F = dhwTankTbl.RefTemp_F(tankIDx);
   dt.PercentLossHr = dhwTankTbl.PercentLossHr(tankIDx);
   dt.HoursHot = dhwTankTbl.HoursHot(tankIDx);
   dt.FracCond = dhwTankTbl.FracCond(tankIDx);
   dt.ControlskW = dhwTankTbl.ControlskW(tankIDx);
    
    dhwTankArray(tankIDx)=dt;
end  % for loop    
% push the DHW pipes into the building

end  %function end statement