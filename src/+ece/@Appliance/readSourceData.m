function applianceArray = readSourceData(fileName)
%fileName to provide excel file path for calcInputs file
%   This method will output an array of appliance objects, one per the row

%% Arguments Block
% Set input argument validation.
arguments
    % fileName: Path to excel file containing appliance data.
    fileName (1,1) string
end %argblock

%% Ensure Path Argument Exists
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(fileName);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load Appliance. Provided file path" + ...
        " ('" + fileName + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Extract Sheets Containing appliance Data
% Get a list of all sheet names, then filter out appliance one.
sheetNames = sheetnames(fileName);
applianceMask = contains(sheetNames,"Appliances");

% Extract appliance Sheet names and count.
applianceSheetNames = sheetNames(applianceMask);
numapplianceSheets = numel(applianceSheetNames);

%% Handle Case: No appliance sheet
% Return early with an empty list of appliance array if there are none to
% import.
if (numapplianceSheets == 0)
    % Set to empty array of appliance objects.
    applianceArray = ece.Appliance.empty(0,1);
    return;
end %endif


%% Read Data from Sheet in Excel File
% Extract Table and remove empty rows.
applianceTbl = readtable(fileName,"Sheet","Appliances", "Range","A2:G19");
applianceTbl = rmmissing(applianceTbl,'DataVariables',{'ApplianceType'});

% Get number of Appliance from table height, and then preallocate output.
numAppliances = height(applianceTbl);
applianceArray = ece.Appliance.empty(numAppliances,0);

% Return empty array if none exist.
emptyCheck = isempty(applianceTbl);
if(emptyCheck)
    applianceArray = ece.Appliance.empty(0,1);
    return;
end %endif

%% Iterate through each row to assign properties
% Populate the Appliance array with the values in the table.
for appIdx = 1:numAppliances
    % Create Instance of Appliance
    % Temporary Appliance for allocating data into one object.
    tempAppliance = ece.Appliance;

    % -- Populate Appliance Object
    % Fill in appliance properties from imported table.
    tempAppliance.ApplianceCategory = applianceTbl.ApplianceCategory(appIdx);
    tempAppliance.ApplianceType = applianceTbl.ApplianceType(appIdx);
    tempAppliance.SubType = applianceTbl.SubType(appIdx);
    tempAppliance.EfficiencyLevel = applianceTbl.EfficiencyLevel(appIdx);
    tempAppliance.Quantity = applianceTbl.Quantity(appIdx);
    tempAppliance.FracUnitsServed = applianceTbl.FracUnitsServed(appIdx);

    % -- Store Constructed Appliance Object
    % Place into position in initialized array.
    applianceArray(appIdx) = tempAppliance;

end %forloop (appIdx)

end %function












