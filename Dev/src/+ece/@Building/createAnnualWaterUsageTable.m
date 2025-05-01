function createAnnualWaterUsageTable(bldg,waterMeters,waterRatios)
%CREATEANNUALWATERUSAGETABLE Method to calculate the annual
%electricity usage table for this building.
%   This method is provided an array of water meters and ratios from
%   which the adjusted usage table is extracted and used to proportionally
%   compute the usage for this building.

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
buildingUsageTbl = table('Size',[0,8],...
    'VariableTypes',["string",repmat("double",1,7)],...
    'VariableNames',["Property","Gallons","AdjGallons","IrrigationGals",...
    "CoolingTowerGals","OtherGals","ResidentialGals","Cost"]);

% Create Default table for accumulating statistical results.
buildingStatsTbl = table('Size',[2,8],...
    'VariableTypes',["string",repmat("double",1,7)],...
    'VariableNames',["Property","Gallons","AdjGallons", ...
        "IrrigationGals","CoolingTowerGals","OtherGals", ...
        "ResidentialGals","Cost"]);

% Set Property Strings
buildingStatsTbl.Property = ["Average";...
    "Fraction of Total"];

% Set default nans
buildingStatsTbl{:,2:end} = nan(2,7);


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
        ["Gallons","Cost","AdjGallons","IrrigationGals", ...
        "CoolingTowerGals","OtherGals","ResidentialGals"]);
    propAdjustedUsageTable{:,:} = propAdjustedUsageTable{:,:} .* wmProp;

    %% Preallocate AnnualUsageTable for Individual Meters
    % This table is going to have 11 columns, and R rows of numeric
    % information. The number of rows is essentially 3 + (numberOfYears).
    % It will be preallocated using a NaN matrix, as that is the
    % default value for unfilled/unused cells.
    nanMatrix = nan(wm.NumberOfYears,8);
    meterUsageTbl = array2table(nanMatrix,...
        "VariableNames",["Property","Gallons","AdjGallons", ...
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
        firstTwelveMonthsYears = year(...
            wm.AdjustedUsageTable.StartDate(monthIndices));
        meterUsageTbl.Property(yearIdx) = ...
            firstTwelveMonthsYears(1);

        % -- Assign Column Values Per Year
        % Extract and compute sums.
        % Gallons
        meterUsageTbl.Gallons(yearIdx) = sum(...
            propAdjustedUsageTable.Gallons(monthIndices));

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
    tempTable = [buildingUsageTbl;meterUsageTbl];

    % Use varfun to assign new table.
    %   InputVariables: Vars to sum together.
    %   GroupingVariables: Vars to group by (ID column)
    buildingUsageTbl = varfun(@sum,tempTable,...
        "GroupingVariables","Property",...
        "InputVariables",["Gallons","AdjGallons", ...
        "IrrigationGals","CoolingTowerGals","OtherGals", ...
        "ResidentialGals","Cost"]);

    % Clear Groupcount Column
    %   This column is added to show how rows are grouped.
    buildingUsageTbl.GroupCount = [];

    % Put original VariableNames Back
    buildingUsageTbl.Properties.VariableNames = ...
        meterUsageTbl.Properties.VariableNames;

    %% Merge Averages into Building StatsTable
    % Set up names of columns that get averaged.
    avgColNames = ["Gallons","AdjGallons", ...
        "IrrigationGals","CoolingTowerGals","OtherGals", ...
        "ResidentialGals","Cost"];

    % Calculate average for columns.
    avgColVals = mean(meterUsageTbl{1:wm.NumberOfYears,avgColNames});

    % Apply average to 1st statistic row
    buildingStatsTbl{1,avgColNames} = sum([...
        buildingStatsTbl{1,avgColNames};...
        avgColVals],...
        1,"omitmissing");

end %forloop (meterIdx)

%% Compute Proportional (Fraction of Total) Usage
% The second row is for proportional usage, and only involves dividing the
% average kWh into other usage columns.
% Set up names of proportional columns
propColNames = ["AdjGallons", ...
    "IrrigationGals","CoolingTowerGals","OtherGals", ...
    "ResidentialGals"];

% Apply average to 2nd statistic row
buildingStatsTbl{2,propColNames} = ...
    buildingStatsTbl{1,propColNames} ./ ...
    buildingStatsTbl.Gallons(1);


%% Merge Tables and Store
% Vertically concatenate the usage and stats table together and assign to
% building usage table.

% Store into Utility
bldg.AnnualWaterUsageTable = [buildingStatsTbl;buildingUsageTbl];

end %function

