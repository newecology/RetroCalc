function applianceArray = ReadSourceData(fileName)
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
numappliance = height(applianceTbl);
applianceArray = ece.Appliance.empty(numappliance,0);

% Return empty array if none exist.
emptyCheck = isempty(applianceTbl);
if(emptyCheck)
    applianceArray = ece.Appliance.empty(0,1);
    return;
end %endif

 %read appliance source data for typical usage
% normally fixed. user can alter if needed
ApplianceDataTbl = ece.Reference.ApplianceDataTable;

% assign a code from the data table to each appliance type 
applianceTbl.Code = string(zeros(numappliance,2));


for codeIdx = 1:numappliance
    if applianceTbl.ApplianceType(codeIdx) ~= "Refrigerators"
        applianceTbl.Code(codeIdx,:) = ApplianceDataTbl.Code(ApplianceDataTbl.ApplianceType == ...
        applianceTbl.ApplianceType(codeIdx) & ...
        ApplianceDataTbl.SubType == applianceTbl.SubType(codeIdx) & ...
        ApplianceDataTbl.EfficiencyLevel == applianceTbl.EfficiencyLevel(codeIdx) )';

    else 
        applianceTbl.Code(codeIdx,:) = ApplianceDataTbl.Code(ApplianceDataTbl.ApplianceType == ...
            applianceTbl.ApplianceType(codeIdx) & ApplianceDataTbl.SubType == ...
            applianceTbl.SubType(codeIdx) )';

    end % if statement
end  % for loop

%% Iterate through each row to assign properties

% Populate the Appliance array with the values in the table.



    for appIdx = 1:numappliance

        % Create Instance of Plumbing Fixture
        % Temporary Slab On grade for allocating data into one object.
        a = ece.Appliance;
        
        a.ApplianceCategory = applianceTbl.ApplianceCategory(appIdx);
        a.ApplianceType = applianceTbl.ApplianceType(appIdx);
        a.SubType = applianceTbl.SubType(appIdx);
        a.EfficiencyLevel = applianceTbl.EfficiencyLevel(appIdx);
        a.EffLevelDescriptor = applianceTbl.EffLevelDescriptor(appIdx);
        a.Quantity = applianceTbl.Quantity(appIdx);
        a.FracUnitsServed = applianceTbl.FracUnitsServed(appIdx);
        a.Code = applianceTbl.Code(appIdx,:);

         % Store Constructed Plumbing Fixture Object
        % Place into position in initialized array.
        applianceArray(appIdx) = a;       

    end % for loop n for appliance table





end  %function end statement












