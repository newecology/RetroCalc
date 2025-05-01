function glazingArray = ReadSourceData(fileName)

%fineName to provide excel file path for calcInputs file
%   This method will output an array of Glazing objects, one per the row

%% Arguments Block
% Set input argument validation.
arguments
    % fileName: Path to excel file containing Glazing data.
    fileName (1,1) string
end %argblock

%% Ensure Path Argument Exists
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(fileName);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load Glazing  data. Provided file path" + ...
        " ('" + fileName + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing Glazing Data
% Get a list of all sheet names, then filter out Glazing one. 
sheetNames = sheetnames(fileName);
glazMask = contains(sheetNames,"Glazing");

% Extract glazing Sheet names and count.
glazSheetNames = sheetNames(glazMask);
numGlazSheets = numel(glazSheetNames);

%% Handle Case: No Glazing sheet
% Return early with an empty list of Glazing array if there are none to
% import.
if (numGlazSheets == 0)
    % Set to empty array of glazing objects.
    glazingArray = ece.Glazing.empty(0,1);
    return;
end %endif


%% Read Data from Sheet in Excel File
% Extract Table and remove empty rows.
glazingTbl = readtable(fileName,"Sheet","Glazing", "Range","A2:V22");
glazingTbl = rmmissing(glazingTbl,'DataVariables',{'GlazingType','Name'});
glazingTbl.ShadingMonthly = [glazingTbl.Jan glazingTbl.Feb glazingTbl.Mar ...
    glazingTbl.Apr glazingTbl.May glazingTbl.Jun glazingTbl.Jul ...
    glazingTbl.Aug glazingTbl.Sep glazingTbl.Oct glazingTbl.Nov ...
    glazingTbl.Dec];
glazingTbl = removevars(glazingTbl, ["Jan", "Feb", "Mar", "Apr", "May", ...
    "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]);

% Get number of glazing objects from table hieght, and then preallocate output.
numGlazing = height(glazingTbl);
glazingArray = ece.Glazing.empty(numGlazing,0);

% Return empty array if none exist.
emptyCheck = isempty(glazingTbl);
if(emptyCheck)
    glazingArray = ece.Glazing.empty(0,1);
    return;
end %endif

%% Iterate through each row to assign properties
for glazIdx = 1:numGlazing 
    % Create Instance of Glazing class
    % Temporary Glazing for allocating data into one object.
    g = ece.Glazing;

    % Read Properties  and assigning to respective properties
    g.GlazingType = glazingTbl.GlazingType(glazIdx);
    g.Name = glazingTbl.Name(glazIdx);
    g.Quantity = glazingTbl.Quantity(glazIdx);
    g.Width_in = glazingTbl.Width_in(glazIdx);
    g.Height_in = glazingTbl.Height_in(glazIdx);
    g.FrameWidth_in = glazingTbl.FrameWidth_in(glazIdx);
    g.Uvalue = glazingTbl.Uvalue(glazIdx);
    g.SHGC = glazingTbl.SHGC(glazIdx);
    g.Azimuth_deg = glazingTbl.Azimuth_deg(glazIdx);
    g.Tilt_deg = glazingTbl.Tilt_deg(glazIdx);
    g.ShadingMonthly = glazingTbl.ShadingMonthly(glazIdx);

    % Store Constructed Glazing Object
    % Place into position in initialized array.
    
    glazingArray(glazIdx) = g;
    
end % for loop

end  %function end statement