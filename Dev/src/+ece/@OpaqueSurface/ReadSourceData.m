function opaqueSurfacesArray = ReadSourceData(fileName)
%fineName to provide excel file path for calcInputs file
%   This method will output an array of OpaqueSurfaces objects, one per the row

%% Arguments Block
% Set input argument validation.
arguments
    % fileName: Path to excel file containing OpaqueSurfaces data.
    fileName (1,1) string
end %argblock

%% Ensure Path Argument Exists
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(fileName);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load OpaqueSurfaces  data. Provided file path" + ...
        " ('" + fileName + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing OpaqueSurfaces Data
% Get a list of all sheet names, then filter out OpaqueSurfaces one. 
sheetNames = sheetnames(fileName);
opaqSurfMask = contains(sheetNames,"OpaqueSurfaces");

% Extract OpaqueSurfaces Sheet names and count.
opaqSheetNames = sheetNames(opaqSurfMask);
numOpaqSurfSheets = numel(opaqSheetNames);

%% Handle Case: No OpaqueSurfaces sheet
% Return early with an empty list of OpaqueSurfaces array if there are none to
% import.
if (numOpaqSurfSheets == 0)
    % Set to empty array of OpaqueSurfaces objects.
    opaqueSurfacesArray = ece.OpaqueSurface.empty(0,1);
    return;
end %endif


%% Read Data from Sheet in Excel File
% Extract Table and remove empty rows.
opaqueSurfaceTbl = readtable(fileName,"Sheet","OpaqueSurfaces", "Range","A2:S22");
opaqueSurfaceTbl = rmmissing(opaqueSurfaceTbl,'DataVariables',{'OpaqueSurfaceType','Name'});
opaqueSurfaceTbl.ShadingMonthly = [opaqueSurfaceTbl.Jan opaqueSurfaceTbl.Feb opaqueSurfaceTbl.Mar ...
    opaqueSurfaceTbl.Apr opaqueSurfaceTbl.May opaqueSurfaceTbl.Jun opaqueSurfaceTbl.Jul ...
    opaqueSurfaceTbl.Aug opaqueSurfaceTbl.Sep opaqueSurfaceTbl.Oct opaqueSurfaceTbl.Nov ...
    opaqueSurfaceTbl.Dec];
opaqueSurfaceTbl = removevars(opaqueSurfaceTbl, ["Jan", "Feb", "Mar", "Apr", "May", ...
    "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]);

% Get number of opaque surfacesfrom table height, and then preallocate output.
numOpaqueSurfaces = height(opaqueSurfaceTbl);
opaqueSurfacesArray = ece.OpaqueSurface.empty(numOpaqueSurfaces,0);

% Return empty array if none exist.
emptyCheck = isempty(opaqueSurfaceTbl);
if(emptyCheck)
    opaqueSurfacesArray = ece.OpaqueSurface.empty(0,1);
    return;
end %endif




%% Iterate through each row to assign properties
% load data into the array
for opaqSurfIdx = 1:numOpaqueSurfaces
        % Create Instance of Opaque Surfaces class
    % Temporary Opaque Surfaces for allocating data into one object.
    os = ece.OpaqueSurface;

    % Read Properties  and assigning to respective properties
    os.Name = opaqueSurfaceTbl.Name(opaqSurfIdx);
    os.OpaqueSurfaceType = opaqueSurfaceTbl.OpaqueSurfaceType(opaqSurfIdx);
    os.Area_ft2 = opaqueSurfaceTbl.Area_ft2(opaqSurfIdx);
    os.RValue = opaqueSurfaceTbl.Rvalue(opaqSurfIdx);
    os.SurfaceEmittance = opaqueSurfaceTbl.SurfaceEmittance(opaqSurfIdx);
    os.Azimuth_deg = opaqueSurfaceTbl.Azimuth_deg(opaqSurfIdx);
    os.Tilt_deg = opaqueSurfaceTbl.Tilt_deg(opaqSurfIdx);
    os.ShadingMonthly = opaqueSurfaceTbl.ShadingMonthly(opaqSurfIdx);
  
    % Store Constructed Opaque Surface Object
    % Place into position in initialized array.
    opaqueSurfacesArray(opaqSurfIdx) = os;

end % for loop

end  %function end statement