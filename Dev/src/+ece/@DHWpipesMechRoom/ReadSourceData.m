function dhwMechArray = ReadSourceData(fileName)
%fileName to provide excel file path for calcInputs file
%   This method will output an array of dhwMech objects, one per the row

%% Arguments Block
% Set input argument validation.
arguments
    % fileName: Path to excel file containing dhwMech data.
    fileName (1,1) string
end %argblock

%% Ensure Path Argument Exists
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(fileName);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load DHW pipes and Mechanical  data. Provided file path" + ...
        " ('" + fileName + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing dhwMech Data
% Get a list of all sheet names, then filter out dhwMech one. 
sheetNames = sheetnames(fileName);
dhwMechMask = contains(sheetNames,"DHWtanksPipes");

% Extract dhwMech Sheet names and count.
dhwMechSheetNames = sheetNames(dhwMechMask);
numdhwMechSheets = numel(dhwMechSheetNames);

%% Handle Case: No dhwMech sheet
% Return early with an empty list of dhwMech array if there are none to
% import.
if (numdhwMechSheets == 0)
    % Set to empty array of dhwMech objects.
    dhwMechArray = ece.DHWpipesMechRoom.empty(0,1);
    return;
end %endif


%% Read Data from Sheet in Excel File
% Extract Table and remove empty rows.
dhwMechTbl = readtable(fileName,"Sheet","DHWtanksPipes", "Range","A9:D20");
dhwMechTbl = rmmissing(dhwMechTbl,'DataVariables',{'PipeDiameter_inch'});

% Get number of opaque surfacesfrom table height, and then preallocate output.
numdhwMech = height(dhwMechTbl);
dhwMechArray = ece.DHWpipesMechRoom.empty(numdhwMech,0);

% Return empty array if none exist.
emptyCheck = isempty(dhwMechTbl);
if(emptyCheck)
    dhwMechArray = ece.DHWpipesMechRoom.empty(0,1);
    return;
end %endif


%% Iterate through each row to assign properties

% Populate the slab on grade array with the values in the table.


    for mechIdx = 1:numdhwMech
        % Create Instance of DHW pipes and Mech class
        % Temporary Slab On grade for allocating data into one object.
        dm = ece.DHWpipesMechRoom;

        dm.PipeDiameter_inch = dhwMechTbl.PipeDiameter_inch(mechIdx);
        dm.PipeType = dhwMechTbl.PipeType(mechIdx);
        dm.HoursHot = dhwMechTbl.HoursHot(mechIdx);
        dm.Length_ft = dhwMechTbl.Length_ft(mechIdx);
 

        dhwMechArray(mechIdx) = dm;
    end % for loop n for fixture table

end  %function end statement