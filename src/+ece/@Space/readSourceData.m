function spaceArray = readSourceData(fileName)
%fileName to provide excel file path for calcInputs file
%   This method will output an array of space objects, one per the row

%% Arguments Block
% Set input argument validation.
arguments
    % fileName: Path to excel file containing space data.
    fileName (1,1) string
end %argblock

%% Ensure Path Argument Exists
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(fileName);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load Space data. Provided file path" + ...
        " ('" + fileName + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing space Data
% Get a list of all sheet names, then filter out space one. 
sheetNames = sheetnames(fileName);
spaceMask = contains(sheetNames,"Spaces");

% Extract space Sheet names and count.
spaceSheetNames = sheetNames(spaceMask);
numspaceSheets = numel(spaceSheetNames);

%% Handle Case: No space sheet
% Return early with an empty list of space array if there are none to
% import.
if (numspaceSheets == 0)
    % Set to empty array of space objects.
    spaceArray = ece.Space.empty(0,1);
    return;
end %endif


%% Read Data from Sheet in Excel File
% Detect import options.
opts = detectImportOptions(fileName,...
    "FileType","spreadsheet",...
    "Sheet","Spaces",...
    "Range","A1:B17");

% Convert Char-Types to String-Types
varCharMask = strcmp(opts.VariableTypes,"char");
opts = setvartype(opts,varCharMask,"string");

% Extract Table and remove empty rows.
spaceTbl = readtable(fileName,opts);
spaceTbl = rmmissing(spaceTbl,"DataVariables","SpaceType");

% Replace NaN values with 0.
spaceTbl = fillmissing(spaceTbl,...
    "constant", 0,...
    "DataVariables",@isnumeric);


% Get number of opaque surfacesfrom table height, and then preallocate output.
numspace = height(spaceTbl);
spaceArray = ece.Space.empty(numspace,0);

% Return empty array if none exist.
emptyCheck = isempty(spaceTbl);
if(emptyCheck)
    spaceArray = ece.Space.empty(0,1);
    return;
end %endif

%% Get the SpaceType Reference Table
% Used to compute some Space properties.
SpaceTypeDataTbl = ece.Reference.SpaceTypeDataTable;

% MW_MISU: This should be moved to the Reference class to filter missing
% rows, NOT in the Space Class.
SpaceTypeDataTbl(SpaceTypeDataTbl.SpaceType == "" , :) = [];

%% Iterate through each row to assign properties
% Populate the spaces array with the values in the table.
for spaceIdx = 1:numspace
    % Create Instance of Space class
    % Temporary space for allocating data into one object.
    s=ece.Space;

    s.SpaceType = spaceTbl.SpaceType(spaceIdx); 
    
    s.Area_ft2 = spaceTbl.Area_ft2(spaceIdx);
    
    s.LPD_Wft2 = SpaceTypeDataTbl.LPD_WFt2(SpaceTypeDataTbl.SpaceType ...
        == s.SpaceType);
    
    s.EPD_Wft2 = SpaceTypeDataTbl.EPD_WFt2(SpaceTypeDataTbl.SpaceType ...
        == s.SpaceType);
    
    s.SensGain_BtuHrPerson = SpaceTypeDataTbl.SensGain_BtuHrPerson...
        (SpaceTypeDataTbl.SpaceType == s.SpaceType);   
    
    s.LatGain_BtuHrPerson = SpaceTypeDataTbl.LatGain_BtuHrPerson...
        (SpaceTypeDataTbl.SpaceType == s.SpaceType);
    
    s.LgtEFLHday = SpaceTypeDataTbl.LgtEFLHday(SpaceTypeDataTbl.SpaceType ...
        == s.SpaceType);
    
    s.EquipEFLHday = SpaceTypeDataTbl.EquipEFLHday(SpaceTypeDataTbl.SpaceType ...
        == s.SpaceType);
    
    s.PeopleEFLHday = SpaceTypeDataTbl.PeopleEFLHday(SpaceTypeDataTbl.SpaceType ...
        == s.SpaceType);
    
    s.Ft2person = SpaceTypeDataTbl.Ft2person(SpaceTypeDataTbl.SpaceType ...
        == s.SpaceType);

        % Store Constructed Slab On grade Object
    % Place into position in initialized array.
   spaceArray(spaceIdx) = s; 
    
end  % for loop


end  %function end statement