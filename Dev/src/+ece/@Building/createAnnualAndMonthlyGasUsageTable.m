function createAnnualAndMonthlyGasUsageTable(bldg,ddTable,gasMeters,gasRatios,...
    numYearsToAvg)
%CREATEANNUALANDMONTHLYGASUSAGETABLE Method to calculate the annual
%gas usage table for this building and the Monthly profile table.
%   This method is provided an array of gas meters and ratios from
%   which the adjusted usage table is extracted and used to proportionally
%   compute the usage for this building.

%% Arguments Block
% Confirm inputs.
arguments
    % bldg: Self-referential Building object.
    bldg (1,1) ece.Building

    % ddTable: Degree days table for corresponding container of utility.
    ddTable table

    % gasMeters: Array of gas meters serving building.
    gasMeters (:,1) ece.Gas

    % gasRatios: Ratio of each meter's usage in building.
    gasRatios (:,1) double

    % numYearsToAvg: Number of years to average together.
    numYearsToAvg (1,1) double = 5;

end %argblock

%% Compute Values from Building-Level
% Get average number of BRs for the building.
avgNumberOfBRs = bldg.BldgNumberOfUnits / bldg.BldgNumberOfUnits;

% Pull required information from the inputs to ease downstream processing.
numMeters = length(gasMeters);

%% Set Up Parameters for MonthlyTable Creation
% -- Create Monthly Profile
% Based off normalized annual Heat Adds on to base usage to have a
% normalized 12-month profile for use in Level 2 calculation. Monthly
% profile starts in January and is normalized to average year weather.
%  The monthly profile is a 12 row (per month) and 5-column table.
%   Table columns are: Month, StoveDryerTherms, DHWTherms, SpaceHeatTherms,
%   and Total.

% Preallocate Monthly matrix of values, the first row being 1:12.
monthlyProfile = zeros(12,5);
monthlyProfile(:,1) = (1:12)';

%% Set Up Parameters for Annual Usage
% Based on the following table properties that are rolled up on a
% meter-by-meter basis.

% Create Default Table for Accumulating Meter Results
buildingUsageTbl = table('Size',[0,9],...
    'VariableTypes',["string",repmat("double",1,8)],...
    'VariableNames',["Property","Therms","AdjTherms","HDD65",...
    "StoveDryerTherms","DHWTherms","SpaceHeatTherms","Cost","HeatSlope"]);

% Create Default Table for Accumulating Statistics
buildingStatsTbl = table('Size',[3,9],...
    'VariableTypes',["string",repmat("double",1,8)],...
    'VariableNames',["Property","Therms","AdjTherms","HDD65",...
    "StoveDryerTherms","DHWTherms","SpaceHeatTherms",...
    "Cost","HeatSlope"]);

% Set Property Strings
buildingStatsTbl.Property = ["Average";...
    "Fraction of Total";...
    "kBtu/ft2"];

% Set default nans
buildingStatsTbl{:,2:end} = nan(3,8);


%% Iterate Through Each Meter
% Each meter will be used to generate an annual usage matrix, which will be
% summed together for the Building's single final annual usage table.

for meterIdx = 1:numMeters
    %% Extract Loop Properties from Input Arrays
    % Extract Meter and Proportion
    gm = gasMeters(meterIdx);
    gmProp = gasRatios(meterIdx);

    % Extract AdjustedUsageTable Section and Proportionalize It
    % Note: The indices pulled are columns from AdjkWh and beyond, and also
    % including the initial kWh.
    propAdjustedUsageTable = gm.AdjustedUsageTable(:,...
        ["Therms","Cost","AdjTherms","DHWTherms"]);
    propAdjustedUsageTable{:,:} = propAdjustedUsageTable{:,:} .* gmProp;

    % Append HDD65Days without needing to proportionalize it.
    propAdjustedUsageTable.HDD65 = gm.AdjustedUsageTable.HDD65;

    %% Compute Appliance Therm Servings
    % For the proportionalAdjustedUsageTable, we want to calculate how much
    % of the heat is used by cooking and drying to factor that out.

    % Cooking Therms
    if (gm.IsCooking)
        % Compute Therms from number of Stoves and Stove Reference.
        gasStoveAnnualTherms = ...
            (ece.Reference.StoveDataTbl.constant(7) + ...
            avgNumberOfBRs * ece.Reference.StoveDataTbl.avgNumBRmult(7));
    else
        % Set value to zero.
        gasStoveAnnualTherms = 0;
    end %endif

    % Dryer Therms
    if (gm.IsClothesDryer)
        % Compute InUnit Dryer
        gasInUnitDryerAnnualTherms = ...
            ((ece.Reference.DryerDataTbl.constant(7) + ...
            avgNumberOfBRs * ece.Reference.DryerDataTbl.avgNumBRmult(7)) * ...
            ece.Reference.DryerDataTbl.factorF(7));

        % Compute Common Dryer
        gasCommonAreaDryerAnnualTherms = ...
            ((ece.Reference.DryerDataTbl.constant(8) + ...
            avgNumberOfBRs * ece.Reference.DryerDataTbl.avgNumBRmult(8)) * ...
            ece.Reference.DryerDataTbl.factorF(8));
    else
        % Set values to zero.
        gasInUnitDryerAnnualTherms = 0;
        gasCommonAreaDryerAnnualTherms = 0;
    end %endif

    %% Get Net Therms and Append to Adjusted Usage Table
    % Combine all therms that are used for dryer and cooking.
    gasStoveDryerTotalAnnlTherms = gasStoveAnnualTherms + ...
        gasInUnitDryerAnnualTherms + gasCommonAreaDryerAnnualTherms;

    % Create vector of monthly value.
    gasStoveDryerTotalAnnlTherms = (gasStoveDryerTotalAnnlTherms/12) .* ...
        ones(gm.NumMonthsOfData,1);

    % Compute VariableUsage
    %   Difference between gasStove therms and adjustedTherms
    varThermUsage = propAdjustedUsageTable.AdjTherms - ...
        gasStoveDryerTotalAnnlTherms;

    % Append Two Columns to PropAdjustedTable
    % StoveDryerTherms
    propAdjustedUsageTable.StoveDryerTherms = gasStoveDryerTotalAnnlTherms;
    % VariableUsageTherms
    propAdjustedUsageTable.VariableUsageTherms = varThermUsage;

    %% Remove HDDs for Months with No Heating
    % Depending on location, remove HDDs for months when the heating system
    % is turned off.
    % Acquire heat off months.
    heatOffMonths = month(bldg.HeatCoolSeasonStartEndDates(1:2));
    % Reverse to get range of months that heating shouldn't happen within.
    heatOffMonths = [heatOffMonths(2)+1, heatOffMonths(1)-1];

    % Extract Months from AdjustedUsagetAble
    hddMonth = gm.AdjustedUsageTable.Month;

    % Create Mask for values in HDD to sum up.
    hdd65Mask = hddMonth >= heatOffMonths(1) & ...
        hddMonth <= heatOffMonths(2);

    % Zero Out HDD65 Rows that fall within months where heating is not
    % applied.
    propAdjustedUsageTable.HDD65(hdd65Mask) = 0;

    %% Add SpaceHeat Therms
    % Knowing the Gas Use for DHW, the remainder of the variable usage is
    % space heat, which is variable but never negative.
    spaceHeatTherms = propAdjustedUsageTable.VariableUsageTherms - ...
        propAdjustedUsageTable.DHWTherms;
    spaceHeatTherms = max(spaceHeatTherms,0);

    % Assign to Table
    propAdjustedUsageTable.SpaceHeatTherms = spaceHeatTherms;

    %% Adjust Totals so that DHW + Heat is Actual Usage
    % Calculate Proportional Scaler and adjust columns in table.
    propScaler = (sum(propAdjustedUsageTable.DHWTherms,"omitmissing") + ...
        sum(propAdjustedUsageTable.SpaceHeatTherms,"omitmissing")) / ...
        sum(propAdjustedUsageTable.VariableUsageTherms,"omitmissing");

    % Reset DHW/Space with Proportion.
    propAdjustedUsageTable.DHWTherms = ...
        propAdjustedUsageTable.DHWTherms / propScaler;
    propAdjustedUsageTable.SpaceHeatTherms = ...
        propAdjustedUsageTable.SpaceHeatTherms / propScaler;

    %% Preallocate AnnualUsageTable for Individual Meters
    % This table is going to have 9 columns, and R rows of numeric
    % information. The number of rows is essentially 3 + (numberOfYears).
    % It will be preallocated using a NaN matrix, as that is the
    % default value for unfilled/unused cells.
    nanMatrix = nan(gm.NumberOfYears,9);
    meterUsageTbl = array2table(nanMatrix,...
        "VariableNames",["Property","Therms","AdjTherms","HDD65",...
        "StoveDryerTherms","DHWTherms","SpaceHeatTherms","Cost","HeatSlope"]);

    %% Compute Direct Values Annually
    % For each column (except the last two) the first N rows, where N is number
    % of years, corresponds to the sum of the monthly value for that year. To
    % compute these, we will iterate through each year and extract the
    % required values to store in the AnnualUsageTables' first N rows.

    % Iterate through each year.
    for yearIdx = 1:gm.NumberOfYears
        % Compute monthly index
        monthIndices = (1:12) + ((yearIdx-1) * 12);

        % -- Assign Year (as Property)
        % Take the first year that shows up for the set of 12 values.
        firstTwelveMonthsYears = year(...
            gm.AdjustedUsageTable.StartDate(monthIndices));
        meterUsageTbl.Property(yearIdx) = ...
            firstTwelveMonthsYears(1);

        % -- Assign Column Values Per Year
        % Extract and compute sums.
        % Therms
        meterUsageTbl.Therms(yearIdx) = sum(...
            propAdjustedUsageTable.Therms(monthIndices));

        % AdjTherms
        meterUsageTbl.AdjTherms(yearIdx) = sum(...
            propAdjustedUsageTable.AdjTherms(monthIndices));

        % HDD65
        meterUsageTbl.HDD65(yearIdx) = sum(...
            propAdjustedUsageTable.HDD65(monthIndices));

        % StoveDryerTherms
        meterUsageTbl.StoveDryerTherms(yearIdx) = sum(...
            propAdjustedUsageTable.StoveDryerTherms(monthIndices));

        % DHWTherms
        meterUsageTbl.DHWTherms(yearIdx) = sum(...
            propAdjustedUsageTable.DHWTherms(monthIndices));

        % SpaceHeatTherms
        meterUsageTbl.SpaceHeatTherms(yearIdx) = sum(...
            propAdjustedUsageTable.SpaceHeatTherms(monthIndices));

        % Cost
        meterUsageTbl.Cost(yearIdx) = sum(...
            propAdjustedUsageTable.Cost(monthIndices));

        % Heating Slope
        meterUsageTbl.HeatSlope(yearIdx) = ...
            meterUsageTbl.SpaceHeatTherms(yearIdx) ./ ...
            meterUsageTbl.HDD65(yearIdx);

    end %forloop

    %% Merge Into Building UsageTable by Year
    % Append new table underneath existing table.
    tempTable = [buildingUsageTbl;meterUsageTbl];

    % Use varfun to assign new table.
    %   InputVariables: Vars to sum together.
    %   GroupingVariables: Vars to group by (ID column)
    buildingUsageTbl = varfun(@sum,tempTable,...
        "GroupingVariables","Property",...
        "InputVariables",["Therms","AdjTherms","HDD65",...
        "StoveDryerTherms","DHWTherms","SpaceHeatTherms",...
        "Cost","HeatSlope"]);

    % Clear Groupcount Column
    %   This column is added to show how rows are grouped.
    buildingUsageTbl.GroupCount = [];

    % Put original VariableNames Back
    buildingUsageTbl.Properties.VariableNames = ...
        meterUsageTbl.Properties.VariableNames;

    %% Merge Average into BuildingStatsTable
    % Set up names of columns that get averaged.
    avgColNames = ["Therms","AdjTherms","HDD65",...
        "StoveDryerTherms","DHWTherms","SpaceHeatTherms",...
        "Cost"];

    % Calculate averages for columns.
    avgColVals = mean(meterUsageTbl{1:gm.NumberOfYears,avgColNames});

    % Apply average to 1st statistic row
    buildingStatsTbl{1,avgColNames} = sum([...
        buildingStatsTbl{1,avgColNames};...
        avgColVals],...
        1,"omitmissing");


    %% Append Data to Monthly Profile
    % Iteratively extract months from AdjustedUsageTable in month order and ill
    % into the profile.
    for monthIdx = 1:12
        % Get Month Mask from standard Meter table (for rowmask)
        monthMask = gm.AdjustedUsageTable.Month == monthIdx;
        numMonthsFound = sum(monthMask);

        % Extract Therm Values from Proportioned Table
        thermVals = sum(propAdjustedUsageTable{monthMask,...
            ["StoveDryerTherms","DHWTherms","SpaceHeatTherms"]}) / ...
            numMonthsFound;

        % Assign via addition to MonthlyProfile
        monthlyProfile(monthIdx,2:4) = monthlyProfile(monthIdx,2:4) + ...
            thermVals;

    end %forloop


end %forloop (meterIdx)


%% Compute Proportional (Fraction of Total) Usage
% The second row is for proportional usage, and only involves dividing the
% average kWh into other usage columns.
% Set up names of proportional columns
propColNames = ["AdjTherms","StoveDryerTherms","DHWTherms",...
    "SpaceHeatTherms"];

% Apply average to 2nd statistic row
buildingStatsTbl{2,propColNames} = ...
    buildingStatsTbl{1,propColNames} ./ ...
    buildingStatsTbl.Therms(1);

%% Compute Value in Area Units
% The current usage values are all basis, and need to be converted to units
% of kBtu/area (where area is provided in square feet).
% Set up name of area columns.
areaColNames = ["Therms","AdjTherms","StoveDryerTherms","DHWTherms",...
    "SpaceHeatTherms"];

% Convert average value into per unit area value.
buildingStatsTbl{3,areaColNames} = ...
    buildingStatsTbl{1,areaColNames} * ...
    (100 / bldg.BldgArea_ft2(3));

%% Compute Heating/Cooling Slopes
% Both of these slopes are computed from the corresponding HDD/CDD column
% and the Heat/Cool average row.
% Heating Slope
buildingStatsTbl.HeatSlope(1) = buildingStatsTbl.SpaceHeatTherms(1) ./ ...
    buildingStatsTbl.HDD65(1);

%% Merge Tables and Store
% Vertically concatenate the usage and stats table together and assign to
% building usage table.

% Store into Utility
bldg.AnnualGasUsageTable = [buildingStatsTbl;buildingUsageTbl];


%% Normalize Recent Actual Heating/Cooling
% Use the corresponding DD table from the containing area to pull the
% average years temperatures.

% Convert years to average to number of days (sloppily, no leap years)
numDaysToAvg = numYearsToAvg * 365;
lastXYearsIndices = (height(ddTable)+1 - numDaysToAvg) : height(ddTable);

% Obtain month values for the last x years in the dd table.
avgMonths = month(ddTable.Date(lastXYearsIndices));

% Define Summer and Winter month (by month index)
summerMonths = [6,7,8];

% Create summer and winter mask.
summerMask = ismember(avgMonths,summerMonths);

% Pull out Last X HDD/CDD for Correct Months
%   The below line basically pulls the last 5 years of the corresponding
%   column by index, but only those indexes that are marked acceptable by
%   the corresponding mask, resulting in the last 5 years of results that
%   fall in the appropriate months.
avgHDD = ddTable.HDD65(lastXYearsIndices(summerMask));

% Compute Single-Year Average by dividing by number of years
avgHDD = sum(avgHDD) / numYearsToAvg;

% Normalize Yearly Value
normAnnualHeating = avgHDD * bldg.AnnualGasUsageTable.HeatSlope(1);


%% Normalize Monthly Table Results
% Add Normalized Space Heating Profile
gasHeatAdj = normAnnualHeating / sum(monthlyProfile(:,3));
monthlyProfile(:,3) = gasHeatAdj * monthlyProfile(:,3);

% Get Total Normalized Electric Usage
% Add up SpaceHeat, DHWTherm, and StoveDryer
monthlyProfile(:,5) = sum(monthlyProfile(:,2:4),2,"omitmissing");

% Clean any NaN
monthlyProfile(isnan(monthlyProfile)) = 0;

% Convert to table for storage
bldg.MonthlyGasProfile = array2table(monthlyProfile,...
    "VariableNames",["Month","StoveDryerTherms","DHWTherms",...
    "SpaceHeatTherms","Total"]);

end %function

