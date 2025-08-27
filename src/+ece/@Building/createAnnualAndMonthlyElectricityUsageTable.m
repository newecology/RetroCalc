function createAnnualAndMonthlyElectricityUsageTable(bldg,...
    elecMeters,elecRatios,...
    numYearsToAvg)
%CREATEANNUALANDMONTHLYELECTRICITYUSAGETABLE Method to calculate the annual
%Electricity usage table for this building and the Monthly profile table.
%   This method is provided an array of electric meters and ratios from
%   which the adjusted usage table is extracted and used to proportionally
%   compute the usage for this building.

%% Arguments Block
% Confirm inputs.
arguments
    % bldg: Self-referential Building object.
    bldg (1,1) ece.Building

    % Meters: Array of elec meters serving building.
    elecMeters (:,1) ece.Electricity

    % gasRatios: Ratio of each meter's usage in building.
    elecRatios (:,1) double

    % numYearsToAvg: Number of years to average together.
    numYearsToAvg (1,1) double = 5;

end %argblock

%% Extract Building Props
% Pull out historical degree days table for easier reference.
ddTable = bldg.Location.HistoricalDDTable;

%% Set Up Parameters for MonthlyTable Creation
% -- Create Monthly Profile
% Based off normalized annual Heat Adds on to base usage to have a
% normalized 12-month profile for use in Level 2 calculation. Monthly
% profile starts in January and is normalized to average year weather.
%  The monthly profile is a 12 row (per month) and 5-column table.

% Preallocate Monthly matrix of values, the first row being 1:12.
monthlyProfile = zeros(12,5);
monthlyProfile(:,1) = (1:12)';

%% Set Up Parameters for Annual Usage
% Based on the following table properties that are rolled up on a
% meter-by-meter basis.
% Get number of meters to process.
numMeters = length(elecMeters);

% Define Building Meter Usage Table variables.
bldgUsageVariables = ["Property","MeterCount",...
    "kWh","AdjkWh","HDD65","CDD70",...
    "Base","Heat","Cool","Cost","HeatSlope","CoolSlope"];
numBldgUsageVariables = length(bldgUsageVariables);

% Create Default Table for Accumulating Meter Results
buildingUsageTbl = table('Size',[0,numBldgUsageVariables],...
    'VariableTypes',["string",repmat("double",1,numBldgUsageVariables-1)],...
    'VariableNames',bldgUsageVariables);

% Create Default Table for Accumulating Statistics
buildingStatsTbl = table('Size',[3,numBldgUsageVariables],...
    'VariableTypes',["string",repmat("double",1,numBldgUsageVariables-1)],...
    'VariableNames',bldgUsageVariables);

% Set Property Strings
buildingStatsTbl.Property = ["Average";...
    "Fraction of Total";...
    "kBtu/ft2"];

% Set default values to NaN
buildingStatsTbl{:,2:end} = nan(3,numBldgUsageVariables-1);


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
        ["Usage","Cost","AdjkWh"]);
    propAdjustedUsageTable{:,:} = propAdjustedUsageTable{:,:} .* emProp;

    % Append HDD65Days without needing to proportionalize it.
    propAdjustedUsageTable.HDD65 = em.AdjustedUsageTable.HDD65;
    propAdjustedUsageTable.CDD70 = em.AdjustedUsageTable.CDD70;


    %% Zero Out Summer and Winter Months
    % For each meter we specifically want to zero out the values in the HDD and
    % CDD during the summer and winter months, respectively. This reflects the
    % "reasonableness" that you wouldn't run heating in the summer or cooling
    % in the winter, and would cool in summer and heat in winter.

    % Extract Heating and Cooling Months from Building
    %  Create month vector from start to end as datetime to wrap around
    %  correctly.
    heatingMonths = util.convertMonthsToVector(...
        month(bldg.HeatCoolSeasonStartEndDates(1)),...
        month(bldg.HeatCoolSeasonStartEndDates(2)));
    coolingMonths = util.convertMonthsToVector(...
        month(bldg.HeatCoolSeasonStartEndDates(3)),...
        month(bldg.HeatCoolSeasonStartEndDates(4)));

    % Create Month Index Arrays
    % These masks are the months in which heating/cooling is performed.
    heatingMonthsIndex = month(heatingMonths);
    coolingMonthsIndex = month(coolingMonths);

    % Create cooling and heating mask.
    heatingMask = ismember(em.AdjustedUsageTable.Month,heatingMonthsIndex);
    coolingMask = ismember(em.AdjustedUsageTable.Month,coolingMonthsIndex);

    % Apply mask to zero out the corresponding HDD/CDD values in
    % AdjustedUsageTable.
    % Reflects that heating/cooling is zero on days where there is no
    % heating/cooling performed.
    propAdjustedUsageTable.HDD65(~heatingMask) = 0;
    propAdjustedUsageTable.CDD70(~coolingMask) = 0;


    %% Calculate Percent Days for Heating/Cooling
    % Using the flags for how the heating and cooling are used, we will 
    % further create columns in the proportionalUsageTable to adjust 
    % percentages.

    % Precalculate basis vectors; zero arrays are mostly used anytime at least
    % one flag is false.
    zeroVec = zeros(height(propAdjustedUsageTable),1);

    % Pre-create the PercentHeat/Cool columns for posterity.
    propAdjustedUsageTable.PercentHeat = zeroVec;
    propAdjustedUsageTable.PercentCool = zeroVec;

    if (em.IsSpaceHeat && em.IsCooling)
        % -- Utility is used for both heating and cooling.
        % Compute Proportional Heating and cooling vectors.
        totalHeatCool = (propAdjustedUsageTable.HDD65 + propAdjustedUsageTable.CDD70);
        propHeating = propAdjustedUsageTable.HDD65 / totalHeatCool;

        % Check FractionalLimitsTable to ensure this isn't outside values.
        % Check if heating is outside the range ONLY if it's doing both.

        % Extract Actual Month Index
        % Note: The first dataIdx (1) Month could actually be March,
        % which would need to index into the (3) position.
        monthIdx = em.AdjustedUsageTable.Month;

        % Extract corresponding Monthly Fractional Limit
        minFracLimits = em.HeatFractionLimitsTable.MinHeating(monthIdx);
        maxFracLimits = em.HeatFractionLimitsTable.MaxHeating(monthIdx);

        % Clip PropHeating between min and max.
        %  Note: Clip acts as clamp and brings a value to the closest
        %  value within a range. Vector inputs apply across same index.
        propHeating = clip(propHeating,minFracLimits,maxFracLimits);

        % Adjust Prop Cooling proportionally.
        %   Note: Since this code always runs, propCooling is always set as
        %   the difference from PropHeating.
        propCooling = propHeating - 1;

        % Assign Columns to Table
        propAdjustedUsageTable.PercentHeat = propHeating;
        propAdjustedUsageTable.PercentCool = propCooling;

        % HEHA_NE:
        % The user input electric base adjustment (which in this case 
        % should be slightly less than one to account for some heating and
        % cooling occurring during shoulder months) is used in this case.
        % Default is 0.95.

    elseif (~em.IsSpaceHeat && em.IsCooling)
        % -- Utility is used for only cooling.
        % Retain Zeros in PercentHeat column.
        % Set ones to cooling column for the site heating season, where
        % cooling season is any month with some days of cooling. This is 
        % the same as setting 1 anywhere it IS the cooling mask.
        propAdjustedUsageTable.PercentCool(coolingMask) = 1;

        % HEHA_NE:
        % In this case, set the Electric Base Adjustment to 1.0.
        em.ElecBaseAdj = 1.0;

    elseif (em.IsSpaceHeat && ~em.IsCooling)
        % --- Utility is used for only heating.
        % Retain Zeros in PercentCool column.
        % Set ones to heating column for the site heating season, where
        % heating season is any month with some days of heating. This is 
        % the same as setting 1 anywhere it IS within the heating mask.
        propAdjustedUsageTable.PercentHeat(heatingMask) = 1;

        % HEHA_NE:
        % In this case, set the Electric Base Adjustment to 1.0.
        em.ElecBaseAdj = 1.0;

    else
        % -- Utility is used for neither heating nor cooling.
        % Do nothing additional as columns are already zeroed out, and also
        % set the EBA to 1.0 (per HEHA_NE).
        em.ElecBaseAdj = 1.0;

    end %endif (Heat/Cool determination)

    %% Manage Electric DHW
    % Electric end uses are broken out as much as possible from the utility
    % data.If electricity is used for DHW, it is not possible to break out 
    % end uses and the user will have to calibrate to total electric usage.

    % Check if Electric Meter is used for DHW
    if em.IsDHW
        % NaN-Out the Base, Heat, and Cool values for the proportional
        % table since no real determination can be made.
        % MW_MISU: Discuss what this actually implies - maybe this check
        % should be done earlier to avoid processing.
        % We also may not be able to return, since this method requires
        % more downstream processing.

        % em.AdjustedUsageTable.Base(:) = NaN;
        % em.AdjustedUsageTable.Heat(:) = NaN;
        % em.AdjustedUsageTable.Cool(:) = NaN;
        % 
        % % Calculations for this utility meter are done.
        % return; --> Likley needs to be a continue.

    end %endif (IsDHW

    %% Compute Minumum Adjusted kWh Usage Per Year
    % If electricity is not used for DHW, then usage can be broken out into
    % a base component (lights, plug loads, appliances), cooling, and space
    % heating if any.
    % For each year of data in the utility, get the lowest adjkWh usage.
    % The goal here is create a vector of constant values (by year, such that
    % every 12 months in one year is a single value, but can change year by
    % year).

    % Preallocate array of nans to store minElec value into.
    minElecKwHPerYear = nan(em.NumMonthsOfData,1);

    % Iterate through each year of Utility Data
    for yearIdx = 1:em.NumberOfYears
        % Create Indices for Month
        monthIndices = (1:12) + ((yearIdx-1) * 12);

        % Extract adjusted kWh for provided months.
        monthlyAKWHUsage = propAdjustedUsageTable.AdjkWh(monthIndices);

        % Obtain the average of the two lowest values in the array, and then
        % multiply it by the ElecBaseAdj value.
        avgLowestKWH = mean(mink(monthlyAKWHUsage,2)) * em.ElecBaseAdj;

        % Store into preallocated array via masking.
        minElecKwHPerYear(monthIndices) = avgLowestKWH;

    end %forloop

    % Clear any remaining NaN values (though, logically, there shouldn't be
    % any)
    minElecKwHPerYear(isnan(minElecKwHPerYear)) = [];


    %% Set BaseUsage Values in Table
    % Compute the Base column for the AdjustedUsage table from the calculated
    % values above and the set BaseLoad Amp.

    % HEHA_NE:
    % Initialize BaseAmp from properties of utility. This value is 
    % typically 0.1, which means that usage will be 20% greater in 
    % December than in June due to increased usage for lighting. 
    % This is accomplished by making the computed baseload have a small 
    % sine function variation.

    % Initialize BaseAmp from properties of utility.
    baseAmp = em.BaseElecAmplitude;

    % Calculate Base vector for inclusion in table
    baseUsagePerMonth = minElecKwHPerYear .* ...
        ((1 + (baseAmp/2)) + ...
        (baseAmp / 2) * ...
        (cos((em.AdjustedUsageTable.Month) * (pi/6))));

    % Ensure that the base usage value is at most as much as the corresponding
    % adjkWh amount. Essentially pick the smaller of the two options.
    propAdjustedUsageTable.Base = min(...
        baseUsagePerMonth,propAdjustedUsageTable.AdjkWh);

    %% Compute HVAC Usage Each Month
    % Calculate the HVAC usage (can't be negative) for each month using the
    % base case. This is the subtraction of the adjusted kWh and the
    % just-calculated base value.
    % This can be for space heating or space cooling, if any.

    % Compute HVAC Usage (overall)
    hvacUsage = (propAdjustedUsageTable.AdjkWh - ...
        propAdjustedUsageTable.Base);

    % Assign to Heat/Cool Columns by proportion.
    propAdjustedUsageTable.Heat = hvacUsage .* ...
        propAdjustedUsageTable.PercentHeat;
    propAdjustedUsageTable.Cool = hvacUsage .* ...
        propAdjustedUsageTable.PercentCool;

    %% Proportional Fixing of Usage
    % If the sum of Base, Heat, and Cool columns is different from the
    % correspong sum of all AdjkWh, adjust the Base, Heat, and Cool
    % proportionally so the sum equals the actual value.

    % Sum Adjusted and Usage
    totalAdjkWh = sum(propAdjustedUsageTable.AdjkWh);
    totalUsage = sum(propAdjustedUsageTable{:,["Base","Heat","Cool"]},...
        "all");

    % Convert proportionally if not equal
    if ~(totalUsage == totalAdjkWh)
        % Determine ratio of usage sum to adjusted sum.
        correctRatio = totalAdjkWh/totalUsage;

        % Multiply usage vectors by correction ratio.
        propAdjustedUsageTable{:,["Base","Heat","Cool"]} = ...
            propAdjustedUsageTable{:,["Base","Heat","Cool"]} .* ...
            correctRatio;

    end %endif

    %% Preallocate AnnualUsageTable for Individual Meters
    % This table is going to have N columns, and R rows of numeric
    % information. This shares the same columns as the bldgUsageTable.

    % Create NaN-Populated Default Meter Table
    nanMatrix = nan(em.NumberOfYears,numBldgUsageVariables);
    meterUsageTbl = array2table(nanMatrix,...
        "VariableNames",bldgUsageVariables);

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
        % MeterCount - Always equal to one when added.
        meterUsageTbl.MeterCount(yearIdx) = 1;

        % kWh
        meterUsageTbl.kWh(yearIdx) = sum(...
            propAdjustedUsageTable.Usage(monthIndices));

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
    % Sum selected table variables.
    buildingUsageSumTbl = varfun(@sum,tempTable,...
        "GroupingVariables","Property",...
        "InputVariables",["MeterCount","kWh","AdjkWh",...
        "Base","Heat","Cool","Cost","HeatSlope","CoolSlope"]);

    % Average selected table variables.
    buildingUsageAvgTbl = varfun(@mean,tempTable,...
        "GroupingVariables","Property",...
        "InputVariables",["HDD65","CDD70"]);

    % Clear Groupcount Column
    %   This column is added to show how rows are grouped. We can erase
    %   this because it isn't actually a cumulative addup of meters -that's
    %   what the MeterCount column is for.
    buildingUsageSumTbl.GroupCount = [];
    buildingUsageAvgTbl.GroupCount = [];

    % Combine Varfunned Tables back into Full Table
    % Sum Table
    buildingUsageSumTbl.Properties.VariableNames = ["Property",...
        "MeterCount","kWh","AdjkWh","Base","Heat","Cool","Cost",...
        "HeatSlope","CoolSlope"];
    % Mean Table
    buildingUsageAvgTbl.Properties.VariableNames = ["Property",...
        "HDD65","CDD70"];

    % Join Separated Tables together for BuildingUsageSumTbl
    buildingUsageTbl = join(buildingUsageSumTbl,buildingUsageAvgTbl);

    % Organize Column Variables for Consistency
    tblVariableOrder = meterUsageTbl.Properties.VariableNames;
    buildingUsageTbl = buildingUsageTbl(:,tblVariableOrder);

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


    %% Append Data to Monthly Profile
    % Iteratively extract months from AdjustedUsageTable in month order and
    % fill into the profile.
    for monthIdx = 1:12
        % Get Month Mask from standard Meter table (for rowmask)
        monthMask = em.AdjustedUsageTable.Month == monthIdx;
        numMonthsFound = sum(monthMask);

        % Extract Therm Values from Proportioned Table
        thermVals = sum(propAdjustedUsageTable{monthMask,...
            ["Base","Heat","Cool"]}) / ...
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
    (3413 / 1e3 / bldg.IntConditionedArea_ft2);

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


%% Normalize Recent Actual Heating/Cooling
% Use the corresponding DD table from the containing area to pull the
% average years temperatures.

% Convert years to average to number of days (sloppily, no leap years)
numDaysToAvg = numYearsToAvg * 365;
lastXYearsIndices = (height(ddTable)+1 - numDaysToAvg) : height(ddTable);

% Obtain month values for the last x years in the dd table.
avgMonths = month(ddTable.Date(lastXYearsIndices));

% Define Summer and Winter month (by month index)
summerMonths = [7,8]; % This can just be bldg.HeatCoolSeasonStartEndDate
winterMonths = [11,12,1,2,3,4];

% Create summer and winter mask.
summerMask = ismember(avgMonths,summerMonths);
winterMask = ismember(avgMonths,winterMonths);

% Pull out Last X HDD/CDD for Correct Months
%   The below line basically pulls the last 5 years of the corresponding
%   column by index, but only those indexes that are marked acceptable by
%   the corresponding mask, resulting in the last 5 years of results that
%   fall in the appropriate months.
avgHDD = ddTable.HDD65(lastXYearsIndices(summerMask));
avgCDD = ddTable.CDD70(lastXYearsIndices(winterMask));

% Compute Single-Year Average by dividing by number of years
avgHDD = sum(avgHDD) / numYearsToAvg;
avgCDD = sum(avgCDD) / numYearsToAvg;

% Normalize Yearly Value
normAnnualHeating = avgHDD * bldg.AnnualElectricUsageTable.HeatSlope(1);
normAnnualCooling = avgCDD * bldg.AnnualElectricUsageTable.CoolSlope(1);


%% Normalize Monthly Table Results
% Add Normalized Space Heating Profile
elecHeatAdj = normAnnualHeating / sum(monthlyProfile(:,3));
monthlyProfile(:,3) = elecHeatAdj * monthlyProfile(:,3);

% Add Normalized Space Cooling Profile
elecCoolAdj = normAnnualCooling / sum(monthlyProfile(:,4));
monthlyProfile(:,4) = elecCoolAdj * monthlyProfile(:,4);

% Get Total Normalized Electric Usage
% Add up base, heating, and cooling.
monthlyProfile(:,5) = sum(monthlyProfile(:,2:4),2,"omitmissing");

% Clean any NaN
monthlyProfile(isnan(monthlyProfile)) = 0;

% Convert to table for storage
bldg.MonthlyElectricProfile = array2table(monthlyProfile,...
    "VariableNames",["Month","Base","Heat","Cool","Total"]);

end %function

