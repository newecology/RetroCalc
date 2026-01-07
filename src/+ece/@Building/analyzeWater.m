function analyzeWater(bldg, waterMeters, waterRatios)
%% Arguments Block
% Confirm inputs.
arguments
    % bldg: Self-referential Building object.
    bldg (1,1) ece.Building

    % waterMeters: Array of water meters serving building.
    waterMeters (:,1) ece.Water

    % waterRatios: Ratio of each meter's usage in building.
    waterRatios (:,1) double

end %argblock

%% Set Up Parameters
% Pull required information from the inputs to ease downstream processing.
numMeters = length(waterMeters);

% Create Default Table for Accumulating Meter Results
buildingUsageTbl = table('Size',[0,9],...
    'VariableTypes',["string", repmat("double", 1, 8)],...
    'VariableNames',["Property", "MeterCount", "Gallons", "AdjGallons", "IrrigationGals",...
    "CoolingTowerGals", "OtherGals", "ResidentialGals", "Cost"]);
numBldgUsageVariables = 9;

% Create Default table for accumulating statistical results.
buildingStatsTbl = table('Size',[2,9],...
    'VariableTypes',["string",repmat("double",1,8)],...
    'VariableNames',["Property","MeterCount","Gallons","AdjGallons", ...
        "IrrigationGals","CoolingTowerGals","OtherGals", ...
        "ResidentialGals","Cost"]);

% Set Property Strings
buildingStatsTbl.Property = ["Average";...
    "Fraction of Total"];

% Set default nans
buildingStatsTbl{:,2:end} = nan(2,8);


%% Iterate Through Each Meter
% Each meter will be used to generate an annual usage matrix, which will be
% summed together for the Building's single final annual usage table.

for meterIdx = 1:numMeters
    %% Extract Loop Properties from Input Arrays
    % Extract Meter and Proportion
    wm = waterMeters(meterIdx);
    wmProp = waterRatios(meterIdx);

    % Extract AdjustedUsageTable Section and Proportionalize It
    % Note: The indices pulled are columns from AdjGallons and beyond, and 
    % also including the initial Gallons.
    propAdjustedUsageTable = wm.AdjustedUsageTable(:,...
        ["Usage","Cost","AdjGallons","IrrigationGals", ...
        "CoolingTowerGals","OtherGals","ResidentialGals"]);
    propAdjustedUsageTable{:,:} = propAdjustedUsageTable{:,:} .* wmProp;

    %% Preallocate AnnualUsageTable for Individual Meters
    % This table is going to have 11 columns, and R rows of numeric
    % information. The number of rows is essentially 2 + (numberOfYears).
    % It will be preallocated using a NaN matrix, as that is the
    % default value for unfilled/unused cells.
    nanMatrix = nan(wm.NumberOfYears, numBldgUsageVariables);
    meterUsageTbl = array2table(nanMatrix,...
        "VariableNames",["Property","MeterCount","Gallons","AdjGallons", ...
        "IrrigationGals","CoolingTowerGals","OtherGals", ...
        "ResidentialGals","Cost"]);

    %% Compute Direct Values Annually
    % For each column (except the last two) the first N rows, where N is number
    % of years, corresponds to the sum of the monthly value for that year. To
    % compute these, we will iterate through each year and extract the
    % required values to store in the AnnualUsageTables' first N rows.

    % Iterate through each year.
    for yearIdx = 1:wm.NumberOfYears
        % Compute monthly index
        monthIndices = (1:12) + ((yearIdx-1) * 12);

        % -- Assign Year (as Property)
        % Take the first year that shows up for the set of 12 values.
        firstTwelveMonthsYears = wm.AdjustedUsageTable.Year(monthIndices);
        meterUsageTbl.Property(yearIdx) = ...
            firstTwelveMonthsYears(1);

        % MeterCount - Always equal to one when added.
        meterUsageTbl.MeterCount(yearIdx) = 1;

        % -- Assign Column Values Per Year
        % Extract and compute sums.
        % Gallons
        meterUsageTbl.Gallons(yearIdx) = sum(...
            propAdjustedUsageTable.Usage(monthIndices));

        % AdjGallons
        meterUsageTbl.AdjGallons(yearIdx) = sum(...
            propAdjustedUsageTable.AdjGallons(monthIndices));

        % IrrigationGals
        meterUsageTbl.IrrigationGals(yearIdx) = sum(...
            propAdjustedUsageTable.IrrigationGals(monthIndices));

        % CoolingTowerGals
        meterUsageTbl.CoolingTowerGals(yearIdx) = sum(...
            propAdjustedUsageTable.CoolingTowerGals(monthIndices));

        % OtherGals
        meterUsageTbl.OtherGals(yearIdx) = sum(...
            propAdjustedUsageTable.OtherGals(monthIndices));

        % ResidentialGals
        meterUsageTbl.ResidentialGals(yearIdx) = sum(...
            propAdjustedUsageTable.ResidentialGals(monthIndices));

        % Cost
        meterUsageTbl.Cost(yearIdx) = sum(...
            propAdjustedUsageTable.Cost(monthIndices));

    end %forloop

    %% Merge Into Building UsageTable by Year
    % Append new table underneath existing table.
    tempTable = [buildingUsageTbl; meterUsageTbl];

    % Use varfun to assign new table.
    %   InputVariables: Vars to sum together.
    %   GroupingVariables: Vars to group by (ID column)
    buildingUsageTbl = varfun(@sum, tempTable,...
        "GroupingVariables","Property",...
        "InputVariables",["MeterCount", "Gallons", "AdjGallons", ...
        "IrrigationGals", "CoolingTowerGals", "OtherGals", ...
        "ResidentialGals", "Cost"]);

    % Clear Groupcount Column
    %   This column is added to show how rows are grouped.
    buildingUsageTbl.GroupCount = [];

    % Put original VariableNames Back
    buildingUsageTbl.Properties.VariableNames = ...
        meterUsageTbl.Properties.VariableNames;

    %% Merge Averages into Building StatsTable
    % Set up names of columns that get averaged.
    avgColNames = ["Gallons", "AdjGallons", ...
        "IrrigationGals", "CoolingTowerGals", "OtherGals", ...
        "ResidentialGals", "Cost"];

    % Calculate average for columns.
    avgColVals = mean(meterUsageTbl{1:wm.NumberOfYears, avgColNames}, 1);

    % Apply average to 1st statistic row
    buildingStatsTbl{1, avgColNames} = sum([...
        buildingStatsTbl{1, avgColNames};...
        avgColVals],...
        1, "omitmissing");

end %forloop (meterIdx)

%% Compute Proportional (Fraction of Total) Usage
% The second row is for proportional usage, and only involves dividing the
% average kWh into other usage columns.
% Set up names of proportional columns
propColNames = ["AdjGallons", "IrrigationGals", ...
    "CoolingTowerGals", "OtherGals", "ResidentialGals"];

% Apply average to 2nd statistic row
buildingStatsTbl{2, propColNames} = ...
    buildingStatsTbl{1, propColNames} ./ ...
    buildingStatsTbl.Gallons(1);


%% Merge Tables and Store
% Vertically concatenate the usage and stats table together and assign to
% building usage table.

% Store into Utility
bldg.AnnualWaterUsageTable = [buildingStatsTbl; buildingUsageTbl];

%% Set Up Parameters for MonthlyTable Creation
% Pull required information from the inputs to ease downstream processing.
numMeters = length(waterMeters);


% -- Create Monthly Profile
% Based off normalized annual Heat/Cool. Adds on to base usage to have a
% normalized 12-month profile for use in Level 2 calculation. Monthly
% profile starts in January and is normalized to average year weather.
%  The monthly profile is a 12 row (per month) and 5-column table.
%   Table columns are: Month, IrrigationGals,
%   CoolingTowerGals, OtherGals, ResidentalGals, and Total.

% Preallocate Monthly matrix of values, the first row being 1:12.
monthlyProfile = zeros(12,6);
monthlyProfile(:,1) = (1:12)';

%% Iterate Through Each Meter
% Each meter will be used to generate a monthly usage table, which will be
% summed together for the building's single final MonthlyProfile table.

for meterIdx = 1:numMeters
    %% Extract Loop Properties from Inputs
    % Extract meter and proportion.
    wm = waterMeters(meterIdx);
    wmProp = waterRatios(meterIdx);

    % Extract AdjustedUsageTable Section and Proportionalize It
    % Note: The indices pulled are columns from AdjkWh and beyond, and also
    % including the initial kWh.
    propAdjustedUsageTable = wm.AdjustedUsageTable(:,...
        ["AdjGallons","IrrigationGals",...
        "CoolingTowerGals","OtherGals","ResidentialGals"]);
    propAdjustedUsageTable{:,:} = propAdjustedUsageTable{:,:} .* wmProp;

    % Iteratively extract months from AdjustedUsageTable in month order and ill
    % into the profile.
    for monthIdx = 1:12
        % Get Month Mask from standard Meter table (for rowmask)
        monthMask = wm.AdjustedUsageTable.Month == monthIdx;
        numMonthsFound = sum(monthMask);

        % Extract Gallon Values from Proportioned Table
        gallonVals = sum(propAdjustedUsageTable{monthMask,...
            ["IrrigationGals","CoolingTowerGals",...
            "OtherGals","ResidentialGals","AdjGallons"]}) / ...
            numMonthsFound;

        % Assign via addition to MonthlyProfile
        monthlyProfile(monthIdx,2:6) = monthlyProfile(monthIdx,2:6) + ...
            gallonVals;

    end %forloop

end %forloop

%% Assign to Output
bldg.MonthlyWaterProfile = array2table(monthlyProfile,...
    "VariableNames",["Month","IrrigationGals",...
    "CoolingTowerGals","OtherUseGals","ResidentialGals","TotalGallons"]);

end %function

