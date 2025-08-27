function createAnnualAndMonthlyPropaneUsageTable(bldg,propaneMeters,...
    propaneRatios,numYearsToAvg)
%CREATEANNUALANDMONTHLYPROPANEUSAGETABLE Method to calculate the annual
%Propane usage table for this building and the Monthly profile table.
%   This method is provided an array of Propane meters and ratios from
%   which the adjusted usage table is extracted and used to proportionally
%   compute the usage for this building.

%% Arguments Block
% Confirm inputs.
arguments
    % bldg: Self-referential Building object.
    bldg (1,1) ece.Building

    % propaneMeters: Array of Propane meters serving building.
    propaneMeters (:,1) ece.Propane

    % propaneRatios: Ratio of each meter's usage in building.
    propaneRatios (:,1) double

    % numYearsToAvg: Number of years to average together.
    numYearsToAvg (1,1) double = 5;

end %argblock

%% Extract Building Props
% Pull out historical degree days table for easier reference.
ddTable = bldg.Location.HistoricalDDTable;

%% Compute Values from Building-Level
% Get average number of BRs for the building.
% MW_MISU: Is this the right calculation? This is always 1.
%   This may need to be bldg.NumberOfBedroomUnits .* [1:length(numBrs)]
avgNumberOfBRs = bldg.NumberOfUnits / bldg.NumberOfUnits;

% Pull required information from the inputs to ease downstream processing.
numMeters = length(propaneMeters);

%% Set Up Parameters for MonthlyTable Creation
% -- Create Monthly Profile
% Based off normalized annual Heat Adds on to base usage to have a
% normalized 12-month profile for use in Level 2 calculation. Monthly
% profile starts in January and is normalized to average year weather.
%  The monthly profile is a 12 row (per month) and 5-column table.
%   Table columns are: Month, StoveDryerGallons, DHWGallons, SpaceHeatGallons,
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
    'VariableNames',["Property","Gallons","AdjGallons","HDD65",...
    "StoveDryerGallons","DHWGallons","SpaceHeatGallons","Cost","HeatSlope"]);

% Create Default Table for Accumulating Statistics
buildingStatsTbl = table('Size',[3,9],...
    'VariableTypes',["string",repmat("double",1,8)],...
    'VariableNames',["Property","Gallons","AdjGallons","HDD65",...
    "StoveDryerGallons","DHWGallons","SpaceHeatGallons",...
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
    pm = propaneMeters(meterIdx);
    pmProp = propaneRatios(meterIdx);

    % Extract AdjustedUsageTable Section and Proportionalize It
    % Note: The indices pulled are columns from AdjGallons and beyond, and also
    % including the initial Gallons.
    propAdjustedUsageTable = pm.AdjustedUsageTable(:,...
        ["Usage","Cost","AdjGallons","DHWGallons"]);
    propAdjustedUsageTable{:,:} = propAdjustedUsageTable{:,:} .* pmProp;

     % Append HDD65Days without needing to proportionalize it.
    propAdjustedUsageTable.HDD65 = pm.AdjustedUsageTable.HDD65;

    %% Compute Appliance Gallons Servings
    % For the proportionalAdjustedUsageTable, we want to calculate how much
    % of the heat is used by cooking and drying to factor that out.

    % Cooking Gallons
    if (pm.IsCooking)
        % Compute Gallons from number of Stoves and Stove Reference.
        propaneStoveAnnualGallons = ...
            (ece.Reference.StoveDataTbl.Constant(7) + ...
            avgNumberOfBRs * ece.Reference.StoveDataTbl.AvgNumBRmult(7));
    else
        % Set value to zero.
        propaneStoveAnnualGallons = 0;
    end %endif

    % Dryer Gallons
    if (pm.IsClothesDryer)
        % Compute InUnit Dryer
        propaneInUnitDryerAnnualGallons = ...
            ((ece.Reference.DryerDataTbl.Constant(7) + ...
            avgNumberOfBRs * ece.Reference.DryerDataTbl.AvgNumBRmult(7)) * ...
            ece.Reference.DryerDataTbl.FactorF(7));

        % Compute Common Dryer
        propaneCommonAreaDryerAnnualGallons = ...
            ((ece.Reference.DryerDataTbl.Constant(8) + ...
            avgNumberOfBRs * ece.Reference.DryerDataTbl.AvgNumBRmult(8)) * ...
            ece.Reference.DryerDataTbl.FactorF(8));
    else
        % Set values to zero.
        propaneInUnitDryerAnnualGallons = 0;
        propaneCommonAreaDryerAnnualGallons = 0;

    end %endif

    %% Get Net Gallons and Append to Adjusted Usage Table
    % Combine all Gallons that are used for dryer and cooking.
    propaneStoveDryerTotalAnnlGallons = propaneStoveAnnualGallons + ...
        propaneInUnitDryerAnnualGallons + propaneCommonAreaDryerAnnualGallons;

    % Create vector of monthly value.
    propaneStoveDryerTotalAnnlGallons = ...
        (propaneStoveDryerTotalAnnlGallons/12) .* ...
        ones(pm.NumMonthsOfData,1);

    % Compute VariableUsage
    %   Difference between PropaneStove Gallons and adjustedGallons
    varGalUsage = propAdjustedUsageTable.AdjGallons - ...
        propaneStoveDryerTotalAnnlGallons;

    % Append Two Columns to PropAdjustedTable
    % StoveDryerGallons
    propAdjustedUsageTable.StoveDryerGallons = propaneStoveDryerTotalAnnlGallons;
    % VariableUsageGallons
    propAdjustedUsageTable.VariableUsageGallons = varGalUsage;

    %% Remove HDDs for Months with No Heating
    % Depending on location, remove HDDs for months when the heating system
    % is turned off.
    % Acquire heat off months.
    heatOffMonths = month(bldg.HeatCoolSeasonStartEndDates(1:2));
    % Reverse to get range of months that heating shouldn't happen within.
    heatOffMonths = [heatOffMonths(2)+1, heatOffMonths(1)-1];

    % Extract Months from AdjustedUsagetAble
    hddMonth = pm.AdjustedUsageTable.Month;

    % Create Mask for values in HDD to zero out.
    hdd65ZeroMask = hddMonth >= heatOffMonths(1) & ...
        hddMonth <= heatOffMonths(2);

    % Zero Out HDD65 Rows that fall within months where heating is not
    % applied.
    propAdjustedUsageTable.HDD65(hdd65ZeroMask) = 0;

    %% Add SpaceHeat Gallons
    % Knowing the Propane Use for DHW, the remainder of the variable usage is
    % space heat, which is variable but never negative.
    spaceHeatGallons = propAdjustedUsageTable.VariableUsageGallons - ...
        propAdjustedUsageTable.DHWGallons;
    spaceHeatGallons = max(spaceHeatGallons,0);

    % Assign to Table
    propAdjustedUsageTable.SpaceHeatGallons = spaceHeatGallons;

    %% Adjust Totals so that DHW + Heat is Actual Usage
    % Calculate Proportional Scaler and adjust columns in table.
    propScaler = (sum(propAdjustedUsageTable.DHWGallons,"omitmissing") + ...
        sum(propAdjustedUsageTable.SpaceHeatGallons,"omitmissing")) / ...
        sum(propAdjustedUsageTable.VariableUsageGallons,"omitmissing");

    % Reset DHW/Space with Proportion.
    propAdjustedUsageTable.DHWGallons = ...
        propAdjustedUsageTable.DHWGallons / propScaler;
    propAdjustedUsageTable.SpaceHeatGallons = ...
        propAdjustedUsageTable.SpaceHeatGallons / propScaler;

    %% Preallocate AnnualUsageTable for Individual Meters
    % This table is going to have 9 columns, and R rows of numeric
    % information. The number of rows is essentially 3 + (numberOfYears).
    % It will be preallocated using a NaN matrix, as that is the
    % default value for unfilled/unused cells.
    nanMatrix = nan(pm.NumberOfYears,9);
    meterUsageTbl = array2table(nanMatrix,...
        "VariableNames",["Property","Gallons","AdjGallons","HDD65",...
        "StoveDryerGallons","DHWGallons","SpaceHeatGallons","Cost","HeatSlope"]);

    %% Compute Direct Values Annually
    % For each column (except the last two) the first N rows, where N is number
    % of years, corresponds to the sum of the monthly value for that year. To
    % compute these, we will iterate through each year and extract the
    % required values to store in the AnnualUsageTables' first N rows.

    % Iterate through each year.
    for yearIdx = 1:pm.NumberOfYears
        % Compute monthly index
        monthIndices = (1:12) + ((yearIdx-1) * 12);

        % -- Assign Year (as Property)
        % Take the first year that shows up for the set of 12 values.
        firstTwelveMonthsYears = year(...
            pm.AdjustedUsageTable.StartDate(monthIndices));
        meterUsageTbl.Property(yearIdx) = ...
            firstTwelveMonthsYears(1);

        % -- Assign Column Values Per Year
        % Extract and compute sums.
        % Gallons
        meterUsageTbl.Gallons(yearIdx) = sum(...
            propAdjustedUsageTable.Usage(monthIndices));

        % AdjGallons
        meterUsageTbl.AdjGallons(yearIdx) = sum(...
            propAdjustedUsageTable.AdjGallons(monthIndices));

        % HDD65
        meterUsageTbl.HDD65(yearIdx) = sum(...
            propAdjustedUsageTable.HDD65(monthIndices));

        % StoveDryerGallons
        meterUsageTbl.StoveDryerGallons(yearIdx) = sum(...
            propAdjustedUsageTable.StoveDryerGallons(monthIndices));

        % DHWGallons
        meterUsageTbl.DHWGallons(yearIdx) = sum(...
            propAdjustedUsageTable.DHWGallons(monthIndices));

        % SpaceHeatGallons
        meterUsageTbl.SpaceHeatGallons(yearIdx) = sum(...
            propAdjustedUsageTable.SpaceHeatGallons(monthIndices));

        % Cost
        meterUsageTbl.Cost(yearIdx) = sum(...
            propAdjustedUsageTable.Cost(monthIndices));

        % Heating Slope
        meterUsageTbl.HeatSlope(yearIdx) = ...
            meterUsageTbl.SpaceHeatGallons(yearIdx) ./ ...
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
        "InputVariables",["Gallons","AdjGallons","HDD65",...
        "StoveDryerGallons","DHWGallons","SpaceHeatGallons",...
        "Cost","HeatSlope"]);

    % Clear Groupcount Column
    %   This column is added to show how rows are grouped.
    buildingUsageTbl.GroupCount = [];

    % Put original VariableNames Back
    buildingUsageTbl.Properties.VariableNames = ...
        meterUsageTbl.Properties.VariableNames;

    %% Merge Average into BuildingStatsTable
    % Set up names of columns that get averaged.
    avgColNames = ["Gallons","AdjGallons","HDD65",...
        "StoveDryerGallons","DHWGallons","SpaceHeatGallons",...
        "Cost"];

    % Calculate averages for columns.
    avgColVals = mean(meterUsageTbl{1:pm.NumberOfYears,avgColNames});

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
        monthMask = pm.AdjustedUsageTable.Month == monthIdx;
        numMonthsFound = sum(monthMask);

        % Extract Gallons Values from Proportioned Table
        GallonsVals = sum(propAdjustedUsageTable{monthMask,...
            ["StoveDryerGallons","DHWGallons","SpaceHeatGallons"]}) / ...
            numMonthsFound;

        % Assign via addition to MonthlyProfile
        monthlyProfile(monthIdx,2:4) = monthlyProfile(monthIdx,2:4) + ...
            GallonsVals;

    end %forloop


end %forloop (meterIdx)


%% Compute Proportional (Fraction of Total) Usage
% The second row is for proportional usage, and only involves dividing the
% average kWh into other usage columns.
% Set up names of proportional columns
propColNames = ["AdjGallons","StoveDryerGallons","DHWGallons",...
    "SpaceHeatGallons"];

% Apply average to 2nd statistic row
buildingStatsTbl{2,propColNames} = ...
    buildingStatsTbl{1,propColNames} ./ ...
    buildingStatsTbl.Gallons(1);

%% Compute Value in Area Units
% The current usage values are all basis, and need to be converted to units
% of kBtu/area (where area is provided in square feet).
% Set up name of area columns.
areaColNames = ["Gallons","AdjGallons","StoveDryerGallons","DHWGallons",...
    "SpaceHeatGallons"];

% Convert average value into per unit area value.
buildingStatsTbl{3,areaColNames} = ...
    buildingStatsTbl{1,areaColNames} * ...
    (100 / bldg.IntConditionedArea_ft2);

%% Compute Heating/Cooling Slopes
% Both of these slopes are computed from the corresponding HDD/CDD column
% and the Heat/Cool average row.
% Heating Slope
buildingStatsTbl.HeatSlope(1) = buildingStatsTbl.SpaceHeatGallons(1) ./ ...
    buildingStatsTbl.HDD65(1);

%% Merge Tables and Store
% Vertically concatenate the usage and stats table together and assign to
% building usage table.

% Store into Utility
bldg.AnnualPropaneUsageTable = [buildingStatsTbl;buildingUsageTbl];
%Adding SpaceHeatTherms equivalent column to annual usage for space heat calculation
%in HEA
bldg.AnnualPropaneUsageTable.SpaceHeatTherms = bldg.AnnualPropaneUsageTable.SpaceHeatGallons*0.916;

%Adding DHWTherms equivalent column to annual usage for DHW heat calculation
%in HEA
bldg.AnnualPropaneUsageTable.DHWTherms = bldg.AnnualPropaneUsageTable.DHWGallons*0.916;

%Adding StoveDryerTherms equivalent column to annual usage for Appliance heat calculation
%in HEA
bldg.AnnualPropaneUsageTable.StoveDryerTherms = bldg.AnnualPropaneUsageTable.StoveDryerGallons*0.916;

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
normAnnualHeating = avgHDD * bldg.AnnualPropaneUsageTable.HeatSlope(1);


%% Normalize Monthly Table Results
% Add Normalized Space Heating Profile
PropaneHeatAdj = normAnnualHeating / sum(monthlyProfile(:,3));
monthlyProfile(:,3) = PropaneHeatAdj * monthlyProfile(:,3);

% Get Total Normalized Electric Usage
% Add up SpaceHeat, DHWGallons, and StoveDryer
monthlyProfile(:,5) = sum(monthlyProfile(:,2:4),2,"omitmissing");

% Clean any NaN
monthlyProfile(isnan(monthlyProfile)) = 0;

% Convert to table for storage
bldg.MonthlyPropaneProfile = array2table(monthlyProfile,...
    "VariableNames",["Month","StoveDryerGallons","DHWGallons",...
    "SpaceHeatGallons","Total"]);

end %function

