function plumbFixtureArray = ReadSourceData(fileName)
%fileName to provide excel file path for calcInputs file
%   This method will output an array of plumbFixture objects, one per the row

%% Arguments Block
% Set input argument validation.
arguments
    % fileName: Path to excel file containing plumbFixture data.
    fileName (1,1) string
end %argblock

%% Ensure Path Argument Exists
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(fileName);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load plumbing fixture. Provided file path" + ...
        " ('" + fileName + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing plumbFixture Data
% Get a list of all sheet names, then filter out plumbFixture one. 
sheetNames = sheetnames(fileName);
plumbFixtureMask = contains(sheetNames,"PlumbingFixtures");

% Extract plumbFixture Sheet names and count.
plumbFixtureSheetNames = sheetNames(plumbFixtureMask);
numplumbFixtureSheets = numel(plumbFixtureSheetNames);

%% Handle Case: No plumbFixture sheet
% Return early with an empty list of plumbFixture array if there are none to
% import.
if (numplumbFixtureSheets == 0)
    % Set to empty array of plumbFixture objects.
    plumbFixtureArray = ece.PlumbingFixture.empty(0,1);
    return;
end %endif


%% Read Data from Sheet in Excel File
% Extract Table and remove empty rows.
plumbFixtureTbl = readtable(fileName,"Sheet","PlumbingFixtures", "Range","A2:G20");
plumbFixtureTbl = plumbFixtureTbl(~strcmp(plumbFixtureTbl.FixtureType,'None'),:);
% Get number of Plumbing Fixture from table height, and then preallocate output.
numplumbFixture = height(plumbFixtureTbl);
plumbFixtureArray = ece.PlumbingFixture.empty(numplumbFixture,0);

% Return empty array if none exist.
emptyCheck = isempty(plumbFixtureTbl);
if(emptyCheck)
    plumbFixtureArray = ece.PlumbingFixture.empty(0,1);
    return;
end %endif


%% Iterate through each row to assign properties

% Populate the Plumbing Fixture array with the values in the table.


    for plumbIdx= 1:numplumbFixture
        % Create Instance of Plumbing Fixture
        % Temporary Slab On grade for allocating data into one object.
        p = ece.PlumbingFixture;

        p.PlumbingFixtureType = plumbFixtureTbl.FixtureType(plumbIdx);
        p.Gallons = plumbFixtureTbl.Gallons(plumbIdx);
        p.GallonUnits = plumbFixtureTbl.GallonUnits(plumbIdx);
        p.Uses = plumbFixtureTbl.Uses(plumbIdx);
        p.UsesUnits = plumbFixtureTbl.UsesUnits(plumbIdx);
        p.UseTemp_F = plumbFixtureTbl.UseTemp_F(plumbIdx);
        p.FractionTotal = plumbFixtureTbl.FractionTotal(plumbIdx);

         % Store Constructed Plumbing Fixture Object
        % Place into position in initialized array.
        plumbFixtureArray(plumbIdx) = p;
    end % for loop n for fixture table

end  %function end statement



