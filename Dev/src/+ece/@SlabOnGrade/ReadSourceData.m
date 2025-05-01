function slabArray = ReadSourceData(fileName)
%fileName to provide excel file path for calcInputs file
%   This method will output an array of Slab objects, one per the row

%% Arguments Block
% Set input argument validation.
arguments
    % fileName: Path to excel file containing Slab data.
    fileName (1,1) string
end %argblock

%% Ensure Path Argument Exists
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(fileName);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load Slab on Grade data. Provided file path" + ...
        " ('" + fileName + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing Slab Data
% Get a list of all sheet names, then filter out Slab one. 
sheetNames = sheetnames(fileName);
slabMask = contains(sheetNames,"SlabOnGrade");

% Extract Slab Sheet names and count.
slabSheetNames = sheetNames(slabMask);
numSlabSheets = numel(slabSheetNames);

%% Handle Case: No Slab sheet
% Return early with an empty list of Slab array if there are none to
% import.
if (numSlabSheets == 0)
    % Set to empty array of Slab objects.
    slabArray = ece.SlabOnGrade.empty(0,1);
    return;
end %endif


%% Read Data from Sheet in Excel File
% Extract Table and remove empty rows.
slabTbl = readtable(fileName,"Sheet","SlabOnGrade", "Range","A2:C5");
slabTbl = rmmissing(slabTbl,'DataVariables',{'Perimeter_ft','Ffactor'});

% Get number of opaque surfacesfrom table height, and then preallocate output.
numSlab = height(slabTbl);
slabArray = ece.SlabOnGrade.empty(numSlab,0);

% Return empty array if none exist.
emptyCheck = isempty(slabTbl);
if(emptyCheck)
    slabArray = ece.SlabOnGrade.empty(0,1);
    return;
end %endif

%% Iterate through each row to assign properties


% Populate the slab on grade array with the values in the table.
for slabIdx = 1:numSlab
    % Create Instance of Slab On grade class
    % Temporary Slab On grade for allocating data into one object.
    s=ece.SlabOnGrade;

    s.Perimeter_ft = slabTbl.Perimeter_ft(slabIdx);
    s.Area_ft2 = slabTbl.Area_ft2(slabIdx);
    s.Ffactor = slabTbl.Ffactor(slabIdx);

    % Store Constructed Slab On grade Object
    % Place into position in initialized array.
    slabArray(slabIdx) = s;
 
end  % for loop




















end  %function end statement