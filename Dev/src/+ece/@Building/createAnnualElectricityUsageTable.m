function createAnnualElectricityUsageTable(bldg,elecMeters,elecRatios)
%CREATEANNUALELECTRICITYUSAGETABLE Method to calculate the annual
%electricity usage table for this building.
%   This method is provided an array of electricity meters and ratios from
%   which the adjusted usage table is extracted and used to proportionally
%   compute the usage for this building.

%% Arguments Block
% Confirm inputs.
arguments
    % bldg: Self-referential Building object.
    bldg (1,1) ece.Building

    % elecMeters: Array of electricity meters serving building.
    elecMeters (:,1) ece.Electricity

    % elecRatios: Ratio of each meter's usage in building.
    elecRatios (:,1) double

end %argblock

%% Set Up Parameters
% Pull required information from the inputs to ease downstream processing.
numMeters = length(elecMeters);

% Create Default Table for Accumulating Meter
buildingUsageTbl = table('Size',[0,11],...
    'VariableTypes',["string",repmat("double",1,10)],...
    'VariableNames',["Property","kWh","AdjkWh","HDD65","CDD70",...
        "Base","Heat","Cool","Cost","HeatSlope","CoolSlope"]);

% Create Default Table for Accumulating Statistics
buildingStatsTbl = table('Size',[3,11],...
    'VariableTypes',["string",repmat("double",1,10)],...
    'VariableNames',["Property","kWh","AdjkWh","HDD65","CDD70",...
        "Base","Heat","Cool","Cost","HeatSlope","CoolSlope"]);

% Set Property Strings
buildingStatsTbl.Property = ["Average";...
    "Fraction of Total";...
    "kBtu/ft2"];

% Set default NaNs
buildingStatsTbl{:,2:end} = nan(3,10);


%% Iterate Through Each Meter
% Each meter will be used to generate an annual usage matrix, which will be
% summed together for the Building's single final annual usage table.

for meterIdx = 1:numMeters
    %% Extract Loop Properties from Input Arrays
    % Extract Meter and Proportion
    em = elecMeters(meterIdx);
    emProp = elecRatios(meterIdx);

    % Extract AdjustedUsageTable Section and Proportionalize It
    % Note: The indices pulled are columns from AdjkWh and beyond, and also
    % including the initial kWh.
    propAdjustedUsageTable = em.AdjustedUsageTable(:,...
        ["kWh","Cost","AdjkWh","Base","Heat","Cool"]);
    propAdjustedUsageTable{:,:} = propAdjustedUsageTable{:,:} .* emProp;

    %% Preallocate AnnualUsageTable for Individual Meters
    % This table is going to have 11 columns, and R rows of numeric
    % information (one per year).
    nanMatrix = nan(em.NumberOfYears,11);
    meterUsageTbl = array2table(nanMatrix,...
        "VariableNames",["Property","kWh","AdjkWh","HDD65","CDD70",...
        "Base","Heat","Cool","Cost","HeatSlope","CoolSlope"]);

    %% Compute Direct Values Annually
    % For each column (except the last two) the first N rows, where N is number
    % of years, corresponds to the sum of the monthly value for that year. To
    % compute these, we will iterate through each year and extract the
    % required values to store in the AnnualUsageTables' first N rows.

    % Iterate through each year.
    for yearIdx = 1:em.NumberOfYears
        % Compute monthly index
        monthIndices = (1:12) + ((yearIdx-1) * 12);

        % -- Assign Year (as Property)
        % Take the first year that shows up for the set of 12 values.
        firstTwelveMonthsYears = year(...
            em.AdjustedUsageTable.StartDate(monthIndices));
        meterUsageTbl.Property(yearIdx) = ...
            firstTwelveMonthsYears(1);

        % -- Assign Column Values Per Year
        % Extract and compute sums.
        % kWh
        meterUsageTbl.kWh(yearIdx) = sum(...
            propAdjustedUsageTable.kWh(monthIndices));

        % AdjkWh
        meterUsageTbl.AdjkWh(yearIdx) = sum(...
            propAdjustedUsageTable.AdjkWh(monthIndices));

        % HDD65 (Pull direct value, not proportioned)
        meterUsageTbl.HDD65(yearIdx) = sum(...
            em.AdjustedUsageTable.HDD65(monthIndices));

        % CDD70 (Pull direct value, not proportioned)
        meterUsageTbl.CDD70(yearIdx) = sum(...
            em.AdjustedUsageTable.CDD70(monthIndices));

        % Base
        meterUsageTbl.Base(yearIdx) = sum(...
            propAdjustedUsageTable.Base(monthIndices));

        % Heat
        meterUsageTbl.Heat(yearIdx) = sum(...
            propAdjustedUsageTable.Heat(monthIndices));

        % Cool
        meterUsageTbl.Cool(yearIdx) = sum(...
            propAdjustedUsageTable.Cool(monthIndices));

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
        "InputVariables",["kWh","AdjkWh","HDD65","CDD70",...
        "Base","Heat","Cool","Cost","HeatSlope","CoolSlope"]);

    % Clear Groupcount Column
    %   This column is added to show how rows are grouped.
    buildingUsageTbl.GroupCount = [];

    % Put original VariableNames Back
    buildingUsageTbl.Properties.VariableNames = ...
        meterUsageTbl.Properties.VariableNames;

    %% Merge Average into Building StatsTable
    % Set up names of columns that get averaged.
    avgColNames = ["kWh","AdjkWh","HDD65","CDD70",...
        "Base","Heat","Cool","Cost"];

    % Calculate average for columns
    avgColVals = mean(meterUsageTbl{1:em.NumberOfYears,avgColNames});

    % Add computed average vector to corresponding row in table, replacing
    % NaNs as needed with 'omitmissing'.
    buildingStatsTbl{1,avgColNames} = sum([...
        buildingStatsTbl{1,avgColNames};...
        avgColVals],...
        1,"omitmissing");


end %forloop (meterIdx)

%% Compute Proportional (Fraction of Total) Usage
% The second row is for proportional usage, and only involves dividing the
% average kWh into other usage columns.
% Set up names of proportional columns
propColNames = ["AdjkWh","Base","Heat","Cool"];

% Apply average to 2nd statistic row
buildingStatsTbl{2,propColNames} = ...
    buildingStatsTbl{1,propColNames} ./ ...
    buildingStatsTbl.kWh(1);

%% Compute Value in Area Units
% The current usage values are all basis, and need to be converted to units
% of kBtu/area (where area is provided in square feet).
% Set up name of area columns.
areaColNames = ["kWh","AdjkWh","Base", "Heat","Cool"];

% Convert average value into per unit area value.
buildingStatsTbl{3,areaColNames} = ...
    buildingStatsTbl{1,areaColNames} * ...
    (3413 / 1e3 / bldg.BldgArea_ft2(3));

%% Compute Heating/Cooling Slopes
% Both of these slopes are computed from the corresponding HDD/CDD column
% and the Heat/Cool average row.
% Heating Slope
buildingStatsTbl.HeatSlope(1) = buildingStatsTbl.Heat(1) ./ ...
    buildingStatsTbl.HDD65(1);

% Cooling Slope
buildingStatsTbl.CoolSlope(1) = buildingStatsTbl.Cool(1) ./ ...
    buildingStatsTbl.CDD70(1);

%% Merge Tables and Store
% Vertically concatenate the usage and stats table together and assign to
% building usage table.

% Store into Utility
bldg.AnnualElectricUsageTable = [buildingStatsTbl;buildingUsageTbl];

end %function

