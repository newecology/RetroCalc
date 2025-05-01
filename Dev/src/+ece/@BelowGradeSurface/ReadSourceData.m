function BGArray = ReadSourceData(fileName)

%fileName to provide excel file path for calcInputs file
%   This method will output an array of BG objects, one per the row

%% Arguments Block
% Set input argument validation.
arguments
    % fileName: Path to excel file containing BG data.
    fileName (1,1) string
end %argblock

%% Ensure Path Argument Exists
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(fileName);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load Below Grade data. Provided file path" + ...
        " ('" + fileName + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing BG Data
% Get a list of all sheet names, then filter out BG one. 
sheetNames = sheetnames(fileName);
BGMask = contains(sheetNames,"env");

% Extract BG Sheet names and count.
BGSheetNames = sheetNames(BGMask);
numBGSheets = numel(BGSheetNames);

%% Handle Case: No BG sheet
% Return early with an empty list of BG array if there are none to
% import.
if (numBGSheets == 0)
    % Set to empty array of BG objects.
    BGArray = ece.BelowGradeSurface.empty(0,1);
    return;
end %endif


%% Read Data from Sheet in Excel File
% Extract Table and remove empty rows.
BGTbl = readtable(fileName,"Sheet","BGsurfaces", "Range","B1:N6");
BGTbl = rmmissing(BGTbl,'DataVariables',{'BGwallArea_ft2','BGwallInsulR'});

% Get number of opaque surfacesfrom table height, and then preallocate output.
numBG = height(BGTbl);
BGArray = ece.BelowGradeSurface.empty(numBG,0);

% Return empty array if none exist.
emptyCheck = isempty(BGTbl);
if(emptyCheck)
    BGArray = ece.BelowGradeSurface.empty(0,1);
    return;
end %endif
%% Getting the soil conductivity table from the Refewrence Table
SoilConductivityTbl=ece.Reference.SoilConductivityTable;
%% Iterate through each row to assign properties

% Populate the slab on grade array with the values in the table.


for bgIdx = 1:numBG
    % Create Instance of Slab On grade class
    % Temporary Slab On grade for allocating data into one object.
    bg=ece.BelowGradeSurface;

    bg.BGwallArea_ft2 = BGTbl.BGwallArea_ft2(bgIdx);
    bg.BGwallInsulR = BGTbl.BGwallInsulR(bgIdx);
    bg.WallInsulDepthBelowGrade_ft = BGTbl.WallInsulDepthBelowGrade_ft(bgIdx);
    bg.BGfloorArea_ft2 = BGTbl.BGfloorArea_ft2(bgIdx);
    bg.BGfloorInsulR = BGTbl.BGfloorInsulR(bgIdx);
    bg.BasementDepthBelowGrade_ft = BGTbl.BasementDepthBelowGrade_ft(bgIdx);
    bg.BasementTemp_F = BGTbl.BasementTemp_F(bgIdx);
    bg.BasementPerimeter_ft = BGTbl.BasementPerimeter_ft(bgIdx);
    bg.BasementMinDimension_ft = BGTbl.BasementMinDimension_ft(bgIdx);
    bg.SoilThermalConductivity = SoilConductivityTbl.value(SoilConductivityTbl.soilType == ...
        BGTbl.SoilThermalConductivity(bgIdx));
    bg.BaseSlabR = SoilConductivityTbl.value(SoilConductivityTbl.soilType == ...
            "R typical uninsulated concrete walls");
    bg.GroundSurfaceTempAmplitude_F = BGTbl.GroundSurfaceTempAmplitude_F(bgIdx);
    bg.GroundMeanAnnualTemp_F = BGTbl.GroundMeanAnnualTemp_F(bgIdx);
    bg.PhaseConstantForTimeLag_days = BGTbl.PhaseConstantForTimeLag_days(bgIdx);

    % Store Constructed Slab On grade Object
    % Place into position in initialized array.
    BGArray(bgIdx) = bg;    
 
end  % for loop


end  %function end statement