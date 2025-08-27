function createAnnualAndMonthlyOilUsageTable(bldg,oilMeters,oilRatios,...
    numYearsToAvg)
%CREATEANNUALANDMONTHLYOILUSAGETABLE Method to calculate the annual
%Oil usage table for this building and the Monthly profile table.
%   This method is provided an array of Oil meters and ratios from
%   which the adjusted usage table is extracted and used to proportionally
%   compute the usage for this building.

%% Arguments Block
% Confirm inputs.
arguments
    % bldg: Self-referential Building object.
    bldg (1,1) ece.Building

    % OilMeters: Array of Oil meters serving building.
    oilMeters (:,1) ece.Oil

    % OilRatios: Ratio of each meter's usage in building.
    oilRatios (:,1) double

    % numYearsToAvg: Number of years to average together.
    numYearsToAvg (1,1) double = 5;

end %argblock

%% Extract Building Props
% Pull out historical degree days table for easier reference.
ddTable = bldg.Location.HistoricalDDTable;

%% Compute Values from Building-Level
% Pull required information from the inputs to ease downstream processing.
numMeters = length(oilMeters);

%% Set Up Parameters for MonthlyTable Creation
% -- Create Monthly Profile
% Based off normalized annual Heat Adds on to base usage to have a
% normalized 12-month profile for use in Level 2 calculation. Monthly
% profile starts in January and is normalized to average year weather.
%  The monthly profile is a 12 row (per month) and 5-column table.
%   Table columns are: Month, StoveDryerGallons, DHWGallons, SpaceHeatGallons,
%   and Total.

% Preallocate Monthly matrix of values, the first row being 1:12.
monthlyProfile = zeros(12,4);
monthlyProfile(:,1) = (1:12)';

%% Set Up Parameters for Annual Usage
% Based on the following table properties that are rolled up on a
% meter-by-meter basis.

% Define VariableNames for the AnnualUsageTable.
annualUsageVariables = ["Property","Gallons","AdjGallons","HDD65",...
    "DHWGallons","SpaceHeatGallons","DHWTherms","SpaceHeatTherms",...
    "Cost","HeatSlope"];
numAnnualTableVars = length(annualUsageVariables);

% Create Default Table for Accumulating Meter Results
buildingUsageTbl = table('Size',[0,numAnnualTableVars],...
    'VariableTypes',["string",repmat("double",1,(numAnnualTableVars-1))],...
    'VariableNames',annualUsageVariables);

% Create Default Table for Accumulating Statistics
buildingStatsTbl = table('Size',[3,numAnnualTableVars],...
    'VariableTypes',["string",repmat("double",1,(numAnnualTableVars-1))],...
    'VariableNames',annualUsageVariables);

% Set Property Strings
buildingStatsTbl.Property = ["Average";...
    "Fraction of Total";...
    "kBtu/ft2"];

% Set default nans
buildingStatsTbl{:,2:end} = nan(3,numAnnualTableVars-1);


%% Iterate Through Each Meter
% Each meter will be used to generate an annual usage matrix, which will be
% summed together for the Building's single final annual usage table.

for meterIdx = 1:numMeters
    %% Extract Loop Properties from Input Arrays
    % Extract Meter and Proportion
    om = oilMeters(meterIdx);
    omProp = oilRatios(meterIdx);

    % Extract AdjustedUsageTable Section and Proportionalize It
    % Note: The indices pulled are columns from AdjGallons and beyond, and also
    % including the initial kWh.
    propAdjustedUsageTable = om.AdjustedUsageTable(:,...
        ["Usage","Cost","AdjGallons","DHWGallons"]);
    propAdjustedUsageTable{:,:} = propAdjustedUsageTable{:,:} .* omProp;

    % Append HDD65Days without needing to proportionalize it.
    propAdjustedUsageTable.HDD65 = om.AdjustedUsageTable.HDD65; 

    %% Remove HDDs for Months with No Heating
    % Depending on location, remove HDDs for months when the heating system
    % is turned off.
    % Acquire heat off months.
    heatOffMonths = month(bldg.HeatCoolSeasonStartEndDates(1:2));
    % Reverse to get range of months that heating shouldn't happen within.
    heatOffMonths = [heatOffMonths(2)+1, heatOffMonths(1)-1];

    % Extract Months from AdjustedUsagetAble
    hddMonth = om.AdjustedUsageTable.Month;

    % Create Mask for values in HDD to zero out.
    hdd65ZeroMask = hddMonth >= heatOffMonths(1) & ...
        hddMonth <= heatOffMonths(2);

    % Zero Out HDD65 Rows that fall within months where heating is not
    % applied.
    propAdjustedUsageTable.HDD65(hdd65ZeroMask) = 0;

    %% Add SpaceHeat Gallons
    % Knowing the Oil Use for DHW, the remainder of the variable usage is
    % space heat, which is variable but never negative.
    spaceHeatGallons = propAdjustedUsageTable.AdjGallons - ...
        propAdjustedUsageTable.DHWGallons;
    spaceHeatGallons = max(spaceHeatGallons,0);

    % Assign to Table
    propAdjustedUsageTable.SpaceHeatGallons = spaceHeatGallons;

    %% Add SpaceHeat and DHW in Therms (from Gallons)
    % Map the oil meter's oil type to a conversion factor to make the
    % SpaceHeatGallons to SpaceHeatTherms.
    % Extract and map OilType
    oilType = om.OilType;
    oilTypeIdx = find(...
        strcmp(oilType,ece.Reference.OilTypeThermsTable.OilType),...
        1,"first");

    % Ensure OilType Exists
    oilTypeExists = ~isempty(oilTypeIdx);
    if ~oilTypeExists
        % Throw oil-type error and pass it back up to workspace.
        msg = "ece.Building::creatAnnualAndMonthlyOiltUsageTable:badOilType\n" + ...
            "OilMeter %d has type of '%s', which is not defined in the " + ...
            "OilType Reference table.\nPlease ensure the oil type is " + ...
            "correct or that the Reference table is up to date.";
        error(msg,meterIdx,oilType);
    end %endif

    % Extract conversion scale.
    thermsPerGallonScaleFactor = ...
        ece.Reference.OilTypeThermsTable.ThermsPerGallon(oilTypeIdx);

    % Compute SpaceHeatTherms from SpaceHeatGallons
    propAdjustedUsageTable.SpaceHeatTherms = ...
        propAdjustedUsageTable.SpaceHeatGallons * ...
        thermsPerGallonScaleFactor;

    % Compute DHWTherms from DHWGallons
    propAdjustedUsageTable.DHWTherms = ...
        propAdjustedUsageTable.DHWGallons * ...
        thermsPerGallonScaleFactor;


    %% Adjust Totals so that DHW + Heat is Actual Usage
    % Calculate Proportional Scaler and adjust columns in table.
    propScaler = (sum(propAdjustedUsageTable.DHWGallons,"omitmissing") + ...
        sum(propAdjustedUsageTable.SpaceHeatGallons,"omitmissing")) / ...
        sum(propAdjustedUsageTable.AdjGallons,"omitmissing");

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
    nanMatrix = nan(om.NumberOfYears,9);
    meterUsageTbl = array2table(nanMatrix,...
        "VariableNames",["Property","Gallons","AdjGallons","HDD65",...
        "DHWGallons","SpaceHeatGallons","SpaceHeatTherms",....
        "Cost","HeatSlope"]);

    %% Compute Direct Values Annually
    % For each column (except the last two) the first N rows, where N is number
    % of years, corresponds to the sum of the monthly value for that year. To
    % compute these, we will iterate through each year and extract the
    % required values to store in the AnnualUsageTables' first N rows.

    % Iterate through each year.
    for yearIdx = 1:om.NumberOfYears
        % Compute monthly index
        monthIndices = (1:12) + ((yearIdx-1) * 12);

        % -- Assign Year (as Property)
        % Take the first year that shows up for the set of 12 values.
        firstTwelveMonthsYears = year(...
            om.AdjustedUsageTable.StartDate(monthIndices));
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

        % DHWGallons
        meterUsageTbl.DHWGallons(yearIdx) = sum(...
            propAdjustedUsageTable.DHWGallons(monthIndices));

        % SpaceHeatGallons
        meterUsageTbl.SpaceHeatGallons(yearIdx) = sum(...
            propAdjustedUsageTable.SpaceHeatGallons(monthIndices));

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
        "DHWGallons","SpaceHeatGallons","DHWTherms","SpaceHeatTherms",...
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
        "DHWGallons","SpaceHeatGallons","DHWTherms","SpaceHeatTherms"...
        "Cost"];

    % Calculate averages for columns.
    avgColVals = mean(meterUsageTbl{1:om.NumberOfYears,avgColNames});

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
        monthMask = om.AdjustedUsageTable.Month == monthIdx;
        numMonthsFound = sum(monthMask);

        % Extract Gallons Values from Proportioned Table
        GallonsVals = sum(propAdjustedUsageTable{monthMask,...
            ["DHWGallons","SpaceHeatGallons"]}) / ...
            numMonthsFound;

        % Assign via addition to MonthlyProfile
        monthlyProfile(monthIdx,2:3) = monthlyProfile(monthIdx,2:3) + ...
            GallonsVals;

    end %forloop


end %forloop (meterIdx)


%% Compute Proportional (Fraction of Total) Usage
% The second row is for proportional usage, and only involves dividing the
% average kWh into other usage columns.
% Set up names of proportional columns
propColNames = ["AdjGallons","DHWGallons",...
    "SpaceHeatGallons","DHWTherms","SpaceHeatTherms"];

% Apply average to 2nd statistic row
buildingStatsTbl{2,propColNames} = ...
    buildingStatsTbl{1,propColNames} ./ ...
    buildingStatsTbl.Gallons(1);

%% Compute Value in Area Units
% The current usage values are all basis, and need to be converted to units
% of kBtu/area (where area is provided in square feet).
% Set up name of area columns.
areaColNames = ["Gallons","AdjGallons","DHWGallons",...
    "SpaceHeatGallons","DHWTherms","SpaceHeatTherms"];

% Convert average value into per unit area value.
% MW_MISU: The constant 1 below was 100 in the Gas calculation, why is it
% changed?
buildingStatsTbl{3,areaColNames} = ...
    buildingStatsTbl{1,areaColNames} * ...
    (1 / bldg.IntConditionedArea_ft2);

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
bldg.AnnualOilUsageTable = [buildingStatsTbl;buildingUsageTbl];

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
normAnnualHeating = avgHDD * bldg.AnnualOilUsageTable.HeatSlope(1);


%% Normalize Monthly Table Results
% Add Normalized Space Heating Profile
OilHeatAdj = normAnnualHeating / sum(monthlyProfile(:,3));
monthlyProfile(:,3) = OilHeatAdj * monthlyProfile(:,3);

% Get Total Normalized Electric Usage
% Add up SpaceHeat, DHWGallons, and StoveDryer
monthlyProfile(:,4) = sum(monthlyProfile(:,2:3),2,"omitmissing");

% Clean any NaN
monthlyProfile(isnan(monthlyProfile)) = 0;

% Convert to table for storage
bldg.MonthlyOilProfile = array2table(monthlyProfile,...
    "VariableNames",["Month","DHWGallons",...
    "SpaceHeatGallons","Total"]);

end %function

