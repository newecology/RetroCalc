function analyzeOil(bldgs, oilMeters, oilRatios, ddTable, numYearsToAvg)
% analyzeOil method to calculate the annual oil usage table for each building
% and the Monthly profile tables.
% For each meter the adjusted usage table and the monthly profile and the
% annual usage table are developed.
% For each building the annual oil usage table and the monthly oil usage profile
% are developed, using the oil meter ratios.


%% Arguments Block
% Confirm inputs.
arguments
    %site (:,1) ece.Site
    
    % bldg: Self-referential Building object.
    bldgs (:,1) ece.Building

    % oilMeters: Array of oil meters serving building.
    oilMeters (:,1) ece.Oil

    % oilRatios: Ratio of each meter's usage in building.
    oilRatios (:,:) double

    % ddTable: Degree days table for corresponding container of utility.
    ddTable table

    % numYearsToAvg: Number of years to average together.
    numYearsToAvg (1,1) double;

end %argblock

%% Compute Values for calculation

% Pull required information from the inputs to ease downstream processing.
numMeters = length(oilMeters);
numBuildings = length(bldgs);

% Get average number of BRs for the building.
% This is the total number of bedrooms divided by the number of dwelling
% units.
avgNumBRs = zeros(1,numBuildings);
for bldgIdx = 1:numBuildings
    avgNumBRs(bldgIdx) = sum(bldgs(bldgIdx).NumberOfBedroomUnits .* [1 2 3 4]) / ...
        bldgs(bldgIdx).NumberOfUnits;
end % if statement

% Identify the meters serving each building
% Logical matrix with rows for each meter and columns for each building
% Based on if the meter ratio for that building is > 0
bldgMeters = zeros(numMeters, numBuildings);
bldgMeters = oilRatios > 0;


%% Analyze usage for each meter

for meterIdx = 1:numMeters
    om = oilMeters(meterIdx);
    
    % If the meter serves DHW loads, calculate the DHW component using the
    % summer minimum and the sunusoidal pattern of DHW energy use.

    if om.IsDHW
        % If the meter does serve DHW, but does not serve space heat, any
        % use must be allocated to DHW.
        if ~om.IsSpaceHeat
            om.AdjustedUsageTable.DHWGallons = om.AdjustedUsageTable.AdjGallons;
            om.AdjustedUsageTable.SpaceHeatGallons = zeros(om.NumMonthsOfData, 1);
        elseif om.IsDHW & om.IsSpaceHeat
        % The meter serves both DHW and space heat. Allocate usage accordingly.
        % In the summer there is no usage for space heat, so all usage is
        % DHW. An annual profile for DHW usage is created from the summer
        % minimum, knowing approximately the extent of the seasonal
        % variability. User can adjust the amplitude. Default is .8,
        % meaning the peak winter DHW energy usage in January is 1.8 times
        % the summer minimum in July.

        % Compute Minumum Adjusted Oil Usage Per month.
        % For each year of data in the utility, get the lowest monthly usage.
        % The goal here is to create a vector of constant values (by year, such that
        % every 12 months in one year is a single value, but can change year by
        % year).

        % Preallocate array of nans to store minElec value into.
        minOilGallonsPerYear = nan(om.NumMonthsOfData, 1);

        % Iterate through each year of Utility Data
        for yearIdx = 1:om.NumberOfYears
            % Create Indices for Month
            monthIndices = (1:12) + ((yearIdx-1) * 12);

            % Extract adjusted gallons for provided months.
            monthlyAdjGalUsage = om.AdjustedUsageTable.AdjGallons(monthIndices);

            % Obtain the average of the two lowest values in the array.
            avgLowestGals = mean(mink(monthlyAdjGalUsage,2));

            % Store into preallocated array via masking.
            minOilGallonsPerYear(monthIndices) = avgLowestGals;

        end %forloop

        % Clear any remaining NaN values (though, logically, there shouldn't be
        % any)
        minOilGallonsPerYear(isnan(minOilGallonsPerYear)) = [];

        % Compute Average oilThermOverall
        minGasOverallAvg = mean(minOilGallonsPerYear, "omitmissing");

        % Set DHWTherms Values in Table
        % Compute the DHW gallons column for the AdjustedUsage table from the
        % calculated values above and the set into AdjustedTable.

        % Initialize DHW Column as zeros.
        om.AdjustedUsageTable.DHWGallons = zeros(om.NumMonthsOfData,1);

        % Compute monthly DHW gallons. Min in July, max in January.
        dhwGals = minGasOverallAvg * ...
            ((1 + (om.SeasonalAmpDHWUse/2)) + ...
            (om.SeasonalAmpDHWUse / 2) * ...
            (cos((om.AdjustedUsageTable.Month-1)*(pi/6))));

        % Assign to DHW therms, noting that DHW therms can't be greater
        % than adjusted therms.
        om.AdjustedUsageTable.DHWGallons = min(dhwGals, ...
            om.AdjustedUsageTable.AdjGallons);

        end % if om.IsSpaceHeat

    elseif ~om.IsDHW
        om.AdjustedUsageTable.DHWGallons = zeros(om.NumMonthsOfData, 1);

    end % if statement DHW

    % If DHW usage has been calculated as zero, because there are months of
    % zero variable usage, and yet the meter is designated as serving DHW
    % loads, throw a non fatal message to user.
    if sum(om.AdjustedUsageTable.DHWGallons) == 0 & om.IsDHW
        fprintf(['DHW usage has been calculated as zero, because there are \n  months ' ...
            'of zero usage, and yet the meter is designated \n as ' ...
            'serving DHW loads. Check end use flags and usage data \n for '])
        disp("oil meter number '" + meterIdx + "'")
    end

    % If the meter serves space heating loads, the remaining usage is space
    % heat.
    if om.IsSpaceHeat
        om.AdjustedUsageTable.SpaceHeatGallons = om.AdjustedUsageTable.AdjGallons - ...
            om.AdjustedUsageTable.DHWGallons;
    elseif ~om.IsSpaceHeat
        om.AdjustedUsageTable.SpaceHeatGallons = zeros(om.NumMonthsOfData, 1);
    end % if statement space heat

    % Develop monthly profile of space heating oil usage based on the usage
    % that would occur in a year of average weather. Average weather is
    % defined as the average number of heating degree days to base 65F over
    % the past X years - usually the past 5 years.

    % Zero out HDD's for non-heating months
    % Base it on the heating season start/end dates for the building with the
    % highest oil meter ratio.
   
    % Find the building, of those served by this meter, with the highest oil ratio.
    [maxRatio, selectedBuilding] = max(bldgMeters(meterIdx,:) .* oilRatios(meterIdx,:));

    % Find heating months for that building. Create month vector from start
    % to end as datetime to wrap around correctly.
    % Future work: don't count months with only 1-4 days of heating season.
    heatingMonths = util.convertMonthsToVector(...
        month(bldgs(selectedBuilding).HeatCoolSeasonStartEndDates(1)),...
        month(bldgs(selectedBuilding).HeatCoolSeasonStartEndDates(2)));

    % Create heating mask.
    heatingMask = ismember(om.AdjustedUsageTable.Month, heatingMonths);

    % Apply mask to zero out the corresponding HDDD values in AdjustedUsageTable.
    om.AdjustedUsageTable.HDD65(~heatingMask) = 0;

    % Calculate the heat slope for this meter. If there is no space
    % heating, it will be zero. Gallons per HDD65.
    heatSlope = sum(om.AdjustedUsageTable.SpaceHeatGallons) / ...
        sum(om.AdjustedUsageTable.HDD65);

    % Make monthly profile for meter.
    % Iteratively extract months from AdjustedUsageTable in month order and fill
    % into the profile.

    % Preallocate Monthly matrix of values, the first row being 1:12.
    monthlyProfile = zeros(12, 4);
    monthlyProfile(:, 1) = (1:12)';

    for monthIdx = 1:12
        % Get Month Mask from standard Meter table (for rowmask)
        monthMask = om.AdjustedUsageTable.Month == monthIdx;
        numMonthsFound = sum(monthMask);

        % Extract gallon values from adjusted usage table.
        % Since there might be only one year of data, make sure to add the
        % "1" to the sum function, summing the columns.
        gallonVals = sum(om.AdjustedUsageTable{monthMask, ...
            ["DHWGallons", "SpaceHeatGallons"]}, 1) / ...
            numMonthsFound;

        % Assign via addition to MonthlyProfile
        monthlyProfile(monthIdx, 2:3) = monthlyProfile(monthIdx,2:3) + ...
            gallonVals;

    end %forloop months

    % Normalize Recent Actual Heating/Cooling
    % Use the corresponding DD table from the containing area to pull the
    % average years temperatures.

    % Convert years to average to number of days (sloppily, no leap years)
    numDaysToAvg = numYearsToAvg * 365;
    lastXYearsIndices = (height(ddTable)+1 - numDaysToAvg) : height(ddTable);

    % Obtain month values for the last x years in the dd table.
    avgMonths = month(ddTable.Date(lastXYearsIndices));

    % Create heating mask for DD table.
    heatingMask = ismember(month(ddTable.Date), heatingMonths);

    % Apply heating mask to zero out the corresponding HDDD values in DD table.
    ddTable.HDD65(~heatingMask) = 0;

    % Pull out Last X HDD/CDD for Correct Months
    %   The below line basically pulls the last 5 years of the corresponding
    %   column by index, but only those indexes that are marked acceptable by
    %   the corresponding mask, resulting in the last 5 years of results that
    %   fall in the appropriate months.
    avgHDD = ddTable.HDD65(lastXYearsIndices);

    % Compute Single-Year Average by dividing by number of years
    avgHDD = sum(avgHDD) / numYearsToAvg;

    % Normalize Yearly Value. This is the energy for space heat in a year
    % with average weather. Gallons
    normAnnualHeating = avgHDD * heatSlope;

    % Normalize Monthly Table Results
    % Add Normalized Space Heating Profile
    % Note, if there are any NaN's in the monthly table for space heat, the
    % sum of that column will be NaN, oilHeatAdj will be NaN, and calc will
    % fail.
    oilHeatAdj = normAnnualHeating / sum(monthlyProfile(:, 3));
    monthlyProfile(:, 3) = oilHeatAdj * monthlyProfile(:, 3);

    % Get Total Normalized Gas Usage
    % Add up StoveDryer, DHWTherm, and SpaceHeat.
    monthlyProfile(:, 4) = sum(monthlyProfile(:, 2:3), 2, "omitmissing");

    % Clean any NaN
    monthlyProfile(isnan(monthlyProfile)) = 0;
    
    % Write monthly profile to oil meter property
    om.MonthlyProfile = array2table(monthlyProfile,...
        "VariableNames", ["Month", "DHWGallons",...
        "SpaceHeatGallons", "TotalGallons"]);

end % for loop for meters

%% Create annual usage table for each meter
% Compute annual values
% For each column (except the last two) the first N rows, where N is number
% of years, corresponds to the sum of the monthly value for that year. To
% compute these, we will iterate through each year and extract the
% required values to store in the AnnualUsageTables' first N rows.

for meterIdx = 1:numMeters
    % Iterate through each meter.

    om = oilMeters(meterIdx);

    % Preallocate AnnualUsageTable for Individual Meters
    % This table is going to have 9 columns, and R rows of numeric
    % information. The number of rows is essentially 2 + (numberOfYears).

    % Define Building Meter Usage Table variables.
    meterUsageVariables = ["Property", "Gallons", "AdjGallons",...
        "HDD65", "DHWGallons", "SpaceHeatGallons", "DHWkBtu", "SpaceHeatkBtu", ...
        "Cost", "HeatSlope"];
    numMeterUsageVariables = length(meterUsageVariables);

    om.AnnualUsageTable = table('Size', [om.NumberOfYears+2, numMeterUsageVariables],...
        'VariableTypes', ["string", repmat("double", 1, numMeterUsageVariables-1)],...
        'VariableNames', meterUsageVariables);

    om.AnnualUsageTable.Property(1:2) = ["Average"; "Fraction Total"];

    % Compute annual values. Sum the 12 monthly values for each year of data
    for yearIdx = 1:om.NumberOfYears
        % Compute monthly index
        monthIndices = (1:12) + ((yearIdx-1) * 12);

        % -- Assign Year (as Property)
        % Identify the 12 month period by the predominant year.
        % If each of the two years has 6 months, take the first year.
        firstTwelveMonthsYears = om.AdjustedUsageTable.Year(monthIndices);
        [C, ia, ic] = unique(om.AdjustedUsageTable.Year(monthIndices));
        if sum((ic == 1)) > 5
            om.AnnualUsageTable.Property(yearIdx+2) = firstTwelveMonthsYears(1);
        else om.AnnualUsageTable.Property(yearIdx+2) = firstTwelveMonthsYears(12);
        end % if statement

        % -- Assign Column Values Per Year
        % Extract and compute sums.
        om.AnnualUsageTable.Gallons(yearIdx+2) = sum(...
            om.AdjustedUsageTable.Usage(monthIndices));

        % AdjTherms
        om.AnnualUsageTable.AdjGallons(yearIdx+2) = sum(...
            om.AdjustedUsageTable.AdjGallons(monthIndices));

        % HDD65
        om.AnnualUsageTable.HDD65(yearIdx+2) = sum(...
            om.AdjustedUsageTable.HDD65(monthIndices));

        % DHW gallons
        om.AnnualUsageTable.DHWGallons(yearIdx+2) = sum(...
            om.AdjustedUsageTable.DHWGallons(monthIndices));

        % SpaceHeat gallons
        om.AnnualUsageTable.SpaceHeatGallons(yearIdx+2) = sum(...
            om.AdjustedUsageTable.SpaceHeatGallons(monthIndices));

        % Cost
        om.AnnualUsageTable.Cost(yearIdx+2) = sum(...
            om.AdjustedUsageTable.Cost(monthIndices));

    end % for loop years

    % Calculate averages for columns and put in row 1 of meter annual usage table.
    % Add fraction of total in row 2.
    avgColNames = ["Gallons", "AdjGallons", "HDD65", "DHWGallons", ...
        "SpaceHeatGallons", "Cost"];
    avgColVals = mean(om.AnnualUsageTable{3:om.NumberOfYears+2, avgColNames}, 1);
    om.AnnualUsageTable{1, avgColNames} = avgColVals;

    % Add heat slope in gallons per HDD65.
    om.AnnualUsageTable.HeatSlope([1, 3:end]) = ...
        om.AnnualUsageTable.SpaceHeatGallons([1, 3:end]) ./ ...
        om.AnnualUsageTable.HDD65([1, 3:end]);

    % Add SpaceHeat and DHW in kBtu (from Gallons)
    % Map the oil meter's oil type to a conversion factor to convert
    % SpaceHeatGallons to SpaceHeatkBtus and DHWGallons to DHWkBtu.
    % Extract and map OilType
    oilType = om.OilType;
    oilTypeIdx = find(...
        strcmp(oilType, ece.Reference.OilTypekBtuTable.OilType),...
        1,"first");

    % Ensure OilType Exists
    oilTypeExists = ~isempty(oilTypeIdx);
    if ~oilTypeExists
        % Throw oil-type error and pass it back up to workspace.
        msg = "ece.Building::creatAnnualAndMonthlyOiltUsageTable:badOilType\n" + ...
            "OilMeter %d has type of '%s', which is not defined in the " + ...
            "OilType Reference table.\nPlease ensure the oil type is " + ...
            "correct or that the Reference table is up to date.";
        error(msg, meterIdx, oilType);
    end %endif

    % Extract conversion scale.
    kBtuPerGallonScaleFactor = ...
        ece.Reference.OilTypekBtuTable.kBtuPerGallon(oilTypeIdx);

    % Compute SpaceHeatkBtu from SpaceHeatGallons
    om.AnnualUsageTable.SpaceHeatkBtu([1, 3:end]) = ...
        om.AnnualUsageTable.SpaceHeatGallons([1, 3:end]) * ...
        kBtuPerGallonScaleFactor;

    % Compute DHW kBtu from DHWGallons
    om.AnnualUsageTable.DHWkBtu([1, 3:end]) = ...
        om.AnnualUsageTable.DHWGallons([1, 3:end]) * ...
        kBtuPerGallonScaleFactor;

    % Find the fraction of total usage for each component.
    fracTotalColNames = ["Gallons", "AdjGallons", "DHWGallons", ...
        "SpaceHeatGallons"];
    fracTotalVals = om.AnnualUsageTable{1, fracTotalColNames} / ...
        om.AnnualUsageTable{1, "Gallons"};
    om.AnnualUsageTable{2, fracTotalColNames} = fracTotalVals;
    om.AnnualUsageTable{2, ["DHWkBtu", "SpaceHeatkBtu"]} = ...
        om.AnnualUsageTable{1, ["DHWkBtu", "SpaceHeatkBtu"]} ./ ...
        sum(om.AnnualUsageTable{1, ["DHWkBtu", "SpaceHeatkBtu"]});

end % for loop meters

%% Combine meters to get annual and monthly profile tables for each building

% For each building, sum the meter annual usage tables and monthly
% profiles serving that building. Add the fraction of each meter that
% applies to the building.

for bldgIdx = 1:numBuildings

    % Define Building Meter Usage Table variables.
    bldgUsageVariables = ["Property", "MeterCount", "HDD65", "TotalGallons", ...
        "DHWGallons", "SpaceHeatGallons", "DHWkBtu", "SpaceHeatkBtu", "Cost"];
    numBldgUsageVariables = length(bldgUsageVariables);

    % Create Default Table for Accumulating Meter Results
    buildingUsageTbl = table('Size',[0, numBldgUsageVariables],...
        'VariableTypes',["string", repmat("double", 1, numBldgUsageVariables-1)], ...
        'VariableNames', bldgUsageVariables);


    % Create Default Table for Accumulating Statistics
    buildingStatsTbl = table('Size',[3, numBldgUsageVariables],...
        'VariableTypes',["string", repmat("double", 1, numBldgUsageVariables-1)], ...
        'VariableNames', bldgUsageVariables);

    % Set Property Strings
    buildingStatsTbl.Property = ["Average";...
        "Fraction of Total";...
        "kBtu/ft2"];

    % Set default nans
    buildingStatsTbl{:, 2:end} = nan(3, numBldgUsageVariables-1);

    % Create table for accumulating monthly profiles
    sumMonthlyProfiles = zeros(12,4);
    sumMonthlyProfiles(:,1) = (1:12)';

    % What meters serve this building? This is all the rows and one column
    % of the logical array for meters serving buildings ("bldgMeters").
    meters = [1:numMeters]';
    thisBldgMeters = meters(bldgMeters(:, bldgIdx));

    % Take each of the meters serving this building in turn.
    for meterIdx = 1:numel(thisBldgMeters)
        om = oilMeters(thisBldgMeters(meterIdx));

        % First part, take fractions of meter annual usage tables for DHW 
        % and space heat and sum. Oil meter ratio applied to this building.
        omRatioBldg = oilRatios(thisBldgMeters(meterIdx), bldgIdx);

        % Create a table with the fraction of meter's usage.
        fracAnnualUsageTable = om.AnnualUsageTable;
        % Remove heating slope from table.
        fracAnnualUsageTable = removevars(fracAnnualUsageTable, "HeatSlope");

        % Add MeterCount variable to the meter's fractional usageTable and 
        % make it the second column.
        fracAnnualUsageTable.MeterCount = ones(om.NumberOfYears+2, 1);
        fracAnnualUsageTable = movevars(fracAnnualUsageTable, ...
            "MeterCount", 'After', "Property");

        % Remove the Gallons and AdjGallons columns from the table and
        % replace with TotalGallons which will be calculated later by adding the
        % DHW and space heating components.
        fracAnnualUsageTable = removevars(fracAnnualUsageTable, ...
            ["Gallons", "AdjGallons"]);
        fracAnnualUsageTable.TotalGallons = nan(om.NumberOfYears+2, 1);
        fracAnnualUsageTable = movevars(fracAnnualUsageTable, ...
            "TotalGallons", 'After', "HDD65");

        % For domestic hot water and space heating, assign fractions of usage to
        % building based on the building oil ratios. Default ratios are based on 
        % the conditioned square footage of the buildings.
        propColNames = ["DHWGallons", "SpaceHeatGallons", "DHWkBtu", "SpaceHeatkBtu"];
        fracAnnualUsageArray = om.AnnualUsageTable{[1, 3:end], propColNames} .* omRatioBldg;
        fracAnnualUsageTable{[1, 3:end], propColNames} = fracAnnualUsageArray;
        
        % Append new table underneath existing table.
        tempTable = [buildingUsageTbl; fracAnnualUsageTable];

        % Use varfun to assign new table.
        %   InputVariables: Variables to sum together.
        %   GroupingVariables: Variables to group by (ID column)
        %   Most variables are summed, but HDD's must be averaged.
        buildingUsageSumTbl = varfun(@sum, tempTable,...
            "GroupingVariables", "Property", ...
            "InputVariables", ["MeterCount", "TotalGallons", "DHWGallons", ...
            "SpaceHeatGallons", "DHWkBtu", "SpaceHeatkBtu",  "Cost"]);

        buildingUsageAvgTbl = varfun(@mean, tempTable, ...
            "GroupingVariables", "Property",...
            "InputVariables", ["HDD65"]);

        % Clear Groupcount Column
        %   This column is added to show how rows are grouped. We can erase
        %   this because it isn't actually a cumulative addup of meters -that's
        %   what the MeterCount column is for.
        buildingUsageSumTbl.GroupCount = [];
        buildingUsageAvgTbl.GroupCount = [];

        % Combine Varfunned Tables back into Full Table with original
        % variable names.
        % Sum Table
        buildingUsageSumTbl.Properties.VariableNames = ["Property", ...
            "MeterCount", "TotalGallons", "DHWGallons", ...
            "SpaceHeatGallons", "DHWkBtu", "SpaceHeatkBtu", "Cost"];
        % Mean Table
        buildingUsageAvgTbl.Properties.VariableNames = ["Property", "HDD65"];

        % Join Separated Tables together for BuildingUsageTbl
        buildingUsageTbl = join(buildingUsageSumTbl, buildingUsageAvgTbl);

        % Restore the original order of variables in the table.
        buildingUsageTbl = movevars(buildingUsageTbl, "HDD65", 'After', ...
            "MeterCount");

        % Second part, take fractions of monthly profiles and sum.
        % Create an array with a fraction of the monthly profile for the
        % columns of DHW and space heating only. 
        fracMonthlyProfileArray = om.MonthlyProfile{:, 2:3} * omRatioBldg;
        % fracMonthlyProfileArray(:, 4) = sum(fracMonthlyProfileArray(:, :), 2);
        sumMonthlyProfiles(:, 2:3) = sumMonthlyProfiles(:, 2:3) + fracMonthlyProfileArray;

    end  % for loop meters

    % Building usage for DHW and space heating has been set by fraction of
    % meter usage to each building. Set cooking/drying for each building as
    % calculated by modeling guidelines in lines 53-106. Set total usage and
    % cost and heating slope.
    
    % Total usage for building is sum of DHW and space heat.
    buildingUsageTbl{1:end-1, "TotalGallons"} = ...
        sum(buildingUsageTbl{1:end-1, ["DHWGallons", "SpaceHeatGallons"]}, 2);
    
    % Cost. Determine the average unit cost for oil from the average 
    % row of each meter's annual usage table. Weighted by the amount of use
    % on the meter.
    for meterIdx = 1:numel(thisBldgMeters)
        meter = thisBldgMeters(meterIdx);
        unitCostOil(meterIdx) = oilMeters(meter).AnnualUsageTable.Cost(1) ...
            / oilMeters(meter).AnnualUsageTable.Gallons(1);
        totalUseMeters(meterIdx) = oilMeters(meter).AnnualUsageTable.Gallons(1);
    end % for loop unit cost

    avgUnitCostGas = sum((unitCostOil .* totalUseMeters)) / sum(totalUseMeters);

    % Determine the cost of oil for each year and for the average year.
    buildingUsageTbl{1:end-1, "Cost"} = ...
        buildingUsageTbl{1:end-1, "TotalGallons"} * avgUnitCostGas;

    % Add heating slope. Gallons/HDD65
    buildingUsageTbl.HeatSlope = nan(numel(buildingUsageTbl.Property), 1);
    buildingUsageTbl.HeatSlope(1:end-1) = ...
        buildingUsageTbl.SpaceHeatGallons(1:end-1) ./ ...
        buildingUsageTbl.HDD65(1:end-1);
    
    % Set up the 2 additional statistics rows of the annual usage table.
    % 1 average usage - already have, 2 fraction of total, 3 kBtu/ft2 .
    % Overwrite values in fraction total row.
    % Set up names of columns to show fraction of use.
    fractionColNames = ["TotalGallons", "DHWGallons", "SpaceHeatGallons"];
    buildingUsageTbl{end, fractionColNames} = buildingUsageTbl{end-1, fractionColNames} / ...
        buildingUsageTbl.TotalGallons(end-1);

    fraction2ColNames = ["DHWkBtu", "SpaceHeatkBtu"];
    buildingUsageTbl{end, fraction2ColNames} = buildingUsageTbl{end-1, fraction2ColNames} ./ ...
        (buildingUsageTbl.DHWkBtu(end-1) + buildingUsageTbl.SpaceHeatkBtu(end-1));

    % The third stats row is kBtu/ft2 area (gross conditioned area in square feet).
    % Set up name of area columns.
    areaColNames = ["DHWkBtu", "SpaceHeatkBtu"];
    
    % Make a temporary table for added row.
    variableNames = ["Property", "MeterCount", "HDD65", "TotalGallons", ...
        "DHWGallons", "SpaceHeatGallons", "DHWkBtu", "SpaceHeatkBtu", ...
        "Cost", "HeatSlope"];
    numBldgUsageVariables2 = length(variableNames);
    kBtuFt2Row = table('Size',[1, numBldgUsageVariables2], ...
        'VariableTypes',["string", repmat("double", 1, numBldgUsageVariables2-1)], ...
        'VariableNames', variableNames);
    kBtuFt2Row.Property(1) = ["kBtu/ft2"];
    kBtuFt2Row{1, areaColNames} = buildingUsageTbl{end-1, areaColNames} ./ ...
        bldgs(bldgIdx).GrossConditionedArea_ft2;
    kBtuFt2Row{1, ["DHWGallons", "SpaceHeatGallons"]} = ...
        kBtuFt2Row{1, ["DHWkBtu", "SpaceHeatkBtu"]};
    kBtuFt2Row{1, "TotalGallons"} = kBtuFt2Row{1, "DHWkBtu"} + ...
        kBtuFt2Row{1, "SpaceHeatkBtu"};

    % Construct the final version of the building usage table with the rows
    % arranged in a logical manner.
    buildingUsageTbl = [buildingUsageTbl(end-1:end, :); ...
        kBtuFt2Row; buildingUsageTbl(1:end-2, :)];
   
    % Clear any nan's from slope variables.
    buildingUsageTbl.HeatSlope(isnan(buildingUsageTbl.HeatSlope)) = 0;

    % Write the annual usage table and monthly profile for the building into
    % its allocated properties
    bldgs(bldgIdx).AnnualOilUsageTable = buildingUsageTbl;

    % Complete the monthly profile sum column.
    sumMonthlyProfiles(:, 4) = sum(sumMonthlyProfiles(:, 2:3), 2);
     bldgs(bldgIdx).MonthlyOilProfile = array2table(sumMonthlyProfiles, ...
        "VariableNames", ["Month", "DHWGallons",...
        "SpaceHeatGallons", "TotalGallons"]);
    % Normalize monthly profile results with annual results total
        % Normalizing the monthly profile values with the Annual Usage totals
     % bldgMonthlyProfile.Total = bldgMonthlyProfile.Total * ... 
     %     bldgs(bldgIdx).AnnualGasUsageTable.TotalTherms(1)/sum(bldgMonthlyProfile.Total);
    
end % building loop

end %function


