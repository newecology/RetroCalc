function analyzePropane(bldgs, propaneMeters, propaneRatios, ddTable, numYearsToAvg)
% analyzePropane method to calculate the annual propane usage table for each building
% and the Monthly profile tables.
% For each meter the adjusted usage table and the monthly profile and the
% annual usage table are developed.
% For each building the annual propane usage table and the monthly propane usage profile
% are developed, using the calculated usage for any cooking or clothes drying 
% appliances, as well as the propane meter ratios for any DHW or space heating usage.


%% Arguments Block
% Confirm inputs.
arguments
    %site (:,1) ece.Site
    
    % bldg: Self-referential Building object.
    bldgs (:,1) ece.Building

    % propaneMeters: Array of propane meters serving building.
    propaneMeters (:,1) ece.Propane

    % propaneRatios: Ratio of each meter's usage in building.
    propaneRatios (:,:) double

    % ddTable: Degree days table for corresponding container of utility.
    ddTable table

    % numYearsToAvg: Number of years to average together.
    numYearsToAvg (1,1) double;

end %argblock

%% Compute Values for calculation

% Pull required information from the inputs to ease downstream processing.
numMeters = length(propaneMeters);
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
bldgMeters = propaneRatios > 0;

%% Determine propane usage for cooking and clothes drying for each building

% Size the vectors for propane cooking/drying usage in each building.
bldgsAnnualPropaneCookingUsage = zeros(1, numBuildings);
bldgsAnnualPropaneInUnitDryerUsage = zeros(1, numBuildings);
bldgsAnnualPropaneCommonAreaDryerUsage = zeros(1, numBuildings);

% Identify the buildings with propane cooking or clothes drying based on the
% meter end use flags, and if true, calculate the annual usage for cooking
% or drying based on the reference data table, and the number of dwelling
% units and the average number of bedrooms per unit. All units in annual gallons.
stoveUsageFlags = [propaneMeters.IsCooking];
inUnitDryerUsageFlags = [propaneMeters.IsInUnitClothesDryer];
commonAreaDryerUsageFlags = [propaneMeters.IsCommonAreaClothesDryer];

for n = 1:numBuildings
    if sum(stoveUsageFlags(bldgMeters(:,n))) > 0
        % Building has propane cooking because at least one propane meter serving
        % that building is flagged as serving cooking.
        bldgsAnnualPropaneCookingUsage(n) = bldgs(n).NumberOfUnits * ...
            (ece.Reference.StoveDataTbl.Constant(7) + ...
            avgNumBRs(n) * ece.Reference.StoveDataTbl.AvgNumBRmult(7));
    end %if propane stoves

    if sum(inUnitDryerUsageFlags(bldgMeters(:,n))) > 0
        % Building has in  unit propane clothes dryers. At least one meter serving the
        % building is flagged as serving clothes dryers.
        % In unit propane dryers
        bldgsAnnualPropaneInUnitDryerUsage(n) = bldgs(n).NumberOfUnits * ...
            ((ece.Reference.DryerDataTbl.Constant(7) + ...
            avgNumBRs(n) * ece.Reference.DryerDataTbl.AvgNumBRmult(7)) * ...
            ece.Reference.DryerDataTbl.FactorF(7));
    end % end if in unit propane dryers

    if sum(commonAreaDryerUsageFlags(bldgMeters(:,n))) > 0
        % Building has common area propane clothes dryers. At least one meter serving the
        % building is flagged as serving clothes dryers.
        % common area propane dryers
        bldgsAnnualPropaneCommonAreaDryerUsage(n) = bldgs(n).NumberOfUnits * ...
            ((ece.Reference.DryerDataTbl.Constant(8) + ...
            avgNumBRs(n) * ece.Reference.DryerDataTbl.AvgNumBRmult(8)) * ...
            ece.Reference.DryerDataTbl.FactorF(8));

    end % if common area propane dryers

end %for buildings propane use cooking/drying

% Combine the propane drying usage for each building.
% Vector of length = number of buildings. Annual gallons.
bldgsAnnualPropaneDryingUsage = ...
    bldgsAnnualPropaneInUnitDryerUsage + bldgsAnnualPropaneCommonAreaDryerUsage;

% Sum the total propane cooking and drying usage for each building.
bldgsAnnualPropaneCookDryUsage = bldgsAnnualPropaneCookingUsage + bldgsAnnualPropaneDryingUsage;

%% Find cooking and drying  usage on each meter

% Method for end uses like cooking or clothes drying that have been
% estimated independent of the meter's usage.

% The different possible meter to building configurations for a particular 
% end use such as propane cooking or propane clothes drying can be represented 
% by a logical array e.g. meterBuildingCookingArray. It is generated by
% [site.propaneMeters.IsCooking]' .* site.BuildingPropaneRatios(>1)

% Assign the estimated building usage to the meters according to the
% pattern of end use served for the meters. Manage four different cases:
% Case 1. One meter serves one building. 1M to 1B.
% Case 2. More than one meter serves a single building. >1M to 1B.
% Case 3. One meter serves multiple buildings. 1M to >1B.
% Case 4. More than one meter serves multiple buildings. >1M to >1B.
% For case 4, note that the analysis cannot be done for "irregular
% configurations," i.e. for non-matrix meter to building patterns,
% where the rows or columns have different sizes.
% So this pattern could be analyzed.
%      B1 B2 B3
% M1   1  1  1
% M2   1  1  1
% But this pattern could not be analyzed correctly.
%      B1 B2 B3
% M1   1  1  1
% M2   1  1  0
% If the input usage flags generate an irregular pattern, the results will
% be incorrect, though in many cases the error is small.

% Set up a logical matrix that identifies the meters serving each building and also
% providing cooking / drying. Array has rows = numMeters, and columns = numBuildings.
% Same procedure for propane cooking and propane clothes drying.
meterBuildingCookingArray = zeros(numMeters, numBuildings);
meterBuildingCookingArray = stoveUsageFlags' .* bldgMeters;
meterBuildingDryingArray = zeros(numMeters, numBuildings);
% Consolidate the usage flags for in unit and common area propane clothes dryers
% (Alternate approach would be to run analysis for in unit and common area
% dryers separately.)
dryerUsageFlags = ([inUnitDryerUsageFlags + commonAreaDryerUsageFlags]) > 0;
meterBuildingDryingArray = dryerUsageFlags' .* bldgMeters;

% Use these vectors to sum the cooking and drying supplied by each meter.
meterPropaneCookingUsage = zeros(1, numMeters);
meterPropaneDryingUsage = zeros(1, numMeters);
meterPropaneCookingAndDryingUsage = zeros(1, numMeters);

% Use these arrays to record the propane usage supplied by each meter to each
% building.
meterBuildingGallonsArrayCooking = zeros(numMeters, numBuildings);
meterBuildingGallonsArrayDrying = zeros(numMeters, numBuildings);

% Shorten variable names.
mbca = meterBuildingCookingArray;
mbda = meterBuildingDryingArray;
Bcook = bldgsAnnualPropaneCookingUsage;
Bdry = bldgsAnnualPropaneDryingUsage;
numM = numMeters;
numB = numBuildings;
Mcook = meterPropaneCookingUsage;
Mdry = meterPropaneDryingUsage;
McookDry = meterPropaneCookingAndDryingUsage;
mbGallonsCook = meterBuildingGallonsArrayCooking;
mbGallonsDry = meterBuildingGallonsArrayDrying;

% For propane cooking
Msums = sum(mbca, 2);
Bsums = sum(mbca, 1);

% Meters serving just one building.
metersTo1B = find(Msums == 1);
% What B's are served by those M's?
[row, bldgsOn1BMs] = find(mbca(metersTo1B, :));
bldgsOn1BMs = unique(bldgsOn1BMs);
% What other meters serve those buildings?
numMsOnThoseBs = sum(mbca(:, bldgsOn1BMs));
% If only 1 M to one of these B's, thats case 1. 1M to 1B.
% Find those buildings by number and their index in the list.
bldgs1M_1B = bldgsOn1BMs(numMsOnThoseBs == 1);
% What meters serve that building(s)?
[meters1M_1B, c]  = find(mbca(:, bldgs1M_1B));
% Assign the building usage(s) to the meter(s).
Mcook(meters1M_1B) = Bcook(bldgs1M_1B);
% Whew! Just did the easiest case! Case 1 done.
% Record the specific usage - gallons of meter to each building.
% Assign values into the mbGallons array.
for n = 1:numel(meters1M_1B)
    mbGallonsCook(meters1M_1B(n), bldgs1M_1B(n)) = Mcook(meters1M_1B(n));
end % for

% If more than one M serves these buildings, it is a case 2.
% >1M to 1B. What B's of those associated with 1B meters are served
% by more than one M?
bldgsMultiM_1B = bldgsOn1BMs(numMsOnThoseBs > 1);
% If there any such cases, analyze.
if bldgsMultiM_1B > 0
    % What other meters are on these buildings?
    % Number of meters on each of the buildings
    totalMtrsOnEachB = sum(mbca(:, bldgsMultiM_1B));
    % Find the meters serving the building(s)
    for n = 1:numel(bldgsMultiM_1B)
        mtrNums = find(mbca(:, bldgsMultiM_1B(n)));
        % Assign the usage to case 2 multi meters serving one building.
        % The usage is divided equally among the meters.
        Mcook(mtrNums) = (1/totalMtrsOnEachB(n)) * Bcook(bldgsMultiM_1B(n));
        % Record the specific usage - gallons of meter to each building.
        for m = 1 : numel(mtrNums)
            mbGallonsCook(mtrNums(m), bldgsMultiM_1B(n)) = Mcook(mtrNums(m));
        end % for loop meter numbers
    end  % for loop buildings
end  % if statement -- if there are any case 2. >1M to 1B.

% Meters that serve more than one building.
metersToMultiB = find(Msums > 1);
% Take each of these meters in turn
for m = 1:numel(metersToMultiB)
    % What B's does this meter serve?
    bldgsOnThisMeter = find(mbca(metersToMultiB(m), :));
    % How many meters serve those buildings?
    numMsOnThoseBs = sum(mbca(:, bldgsOnThisMeter));
    % If there is only 1 M on each of these B's, it's case 3. 1M to >1B.
    if sum(numMsOnThoseBs) == numel(numMsOnThoseBs)
        % Assign sum of building usages to this meter.
        Mcook(metersToMultiB(m)) = sum(Bcook(bldgsOnThisMeter));
        % Record the specific usage - gallons of meter to each building.
        mbGallonsCook(metersToMultiB(m), bldgsOnThisMeter) =  ... 
            Mcook(metersToMultiB(m)) / numel(bldgsOnThisMeter);
    elseif sum(numMsOnThoseBs) > numel(numMsOnThoseBs)
        % There is more than one M on these B's. Case 4. >1M to >1B.
        % Assume a "regular" usage matrix, i.e. it is a matrix.
        % What are the other meters on these buildings?
        [meters, c] = find(mbca(:, bldgsOnThisMeter));
        otherMeters = meters(meters ~= metersToMultiB(m));
        otherMtrOnTheseBs = unique(otherMeters);
        % Assign equally to each meter the sum of the buildings' usage.
        metersIncThisMeter = [metersToMultiB(m) otherMtrOnTheseBs'];
        Mcook(metersIncThisMeter) = (1/numel(metersIncThisMeter)) * sum(Bcook(bldgsOnThisMeter));
            % For case 4, record the specific usage - gallons of meter to each building.            
            for m = 1 : numel(bldgsOnThisMeter)
                for n = 1 : numel(metersIncThisMeter)
                    mbGallonsCook(metersIncThisMeter(n), bldgsOnThisMeter(m)) =  ...
                    Mcook(metersIncThisMeter(n)) / numel(bldgsOnThisMeter);
                end % for meters
            end % for buildings
    end  % if statement case 3 or 4
end  % for loop meters that serve multiple buildings

% Repeat for propane clothes drying.
Msums = sum(mbda, 2);
Bsums = sum(mbda, 1);

% Meters serving just one building.
metersTo1B = find(Msums == 1);
% What B's are served by those M's?
[row, bldgsOn1BMs] = find(mbda(metersTo1B, :));
bldgsOn1BMs = unique(bldgsOn1BMs);
% What other meters serve those buildings?
numMsOnThoseBs = sum(mbda(:, bldgsOn1BMs));
% If only 1 M to one of these B's, thats case 1. 1M to 1B.
% Find those buildings by number and their index in the list.
bldgs1M_1B = bldgsOn1BMs(numMsOnThoseBs == 1);
% What meters serve that building(s)?
[meters1M_1B, c]  = find(mbda(:, bldgs1M_1B));
% Assign the building usage(s) to the meter(s).
Mdry(meters1M_1B) = Bdry(bldgs1M_1B);
% Whew! Just did the easiest case! Case 1 done.
% Record the specific usage - gallons of meter to each building.
% Assign values into the mbGallons array.
for n = 1:numel(meters1M_1B)
    mbGallonsDry(meters1M_1B(n), bldgs1M_1B(n)) = Mdry(meters1M_1B(n));
end % for

% If more than one M serves these buildings, it is a case 2.
% >1M to 1B. What B's of those associated with 1B meters are served
% by more than one M?
bldgsMultiM_1B = bldgsOn1BMs(numMsOnThoseBs > 1);
% If there any such cases, analyze.
if bldgsMultiM_1B > 0
    % What other meters are on these buildings?
    % Number of meters on each of the buildings
    totalMtrsOnEachB = sum(mbda(:, bldgsMultiM_1B));
    % Find the meters serving the building(s)
    for n = 1:numel(bldgsMultiM_1B)
        mtrNums = find(mbda(:, bldgsMultiM_1B(n)));
        % Assign the usage to case 2 multi meters serving one building.
        % The usage is divided equally among the meters.
        Mdry(mtrNums) = (1/totalMtrsOnEachB(n)) * Bdry(bldgsMultiM_1B(n));
        % Record the specific usage - gallons of meter to each building.
        for m = 1 : numel(mtrNums)
            mbGallonsDry(mtrNums(m), bldgsMultiM_1B(n)) = Mdry(mtrNums(m));
        end % for loop meter numbers
    end  % for loop buildings
end  % if statement -- if there are any case 2. >1M to 1B.

% Meters that serve more than one building.
metersToMultiB = find(Msums > 1);
% Take each of these meters in turn
for m = 1:numel(metersToMultiB)
    % What B's does this meter serve?
    bldgsOnThisMeter = find(mbda(metersToMultiB(m), :));
    % How many meters serve those buildings?
    numMsOnThoseBs = sum(mbda(:, bldgsOnThisMeter));
    % If there is only 1 M on each of these B's, it's case 3. 1M to >1B.
    if sum(numMsOnThoseBs) == numel(numMsOnThoseBs)
        % Assign sum of building usages to this meter.
        Mdry(metersToMultiB(m)) = sum(Bdry(bldgsOnThisMeter));
        % Record the specific usage - gallons of meter to each building.
        mbGallonsDry(metersToMultiB(m), bldgsOnThisMeter) =  ... 
            Mdry(metersToMultiB(m)) / numel(bldgsOnThisMeter);
    elseif sum(numMsOnThoseBs) > numel(numMsOnThoseBs)
        % There is more than one M on these B's. Case 4. >1M to >1B.
        % Assume a "regular" usage matrix, i.e. it is a matrix.
        % What are the other meters on these buildings?
        [meters, c] = find(mbda(:, bldgsOnThisMeter));
        otherMeters = meters(meters ~= metersToMultiB(m));
        otherMtrOnTheseBs = unique(otherMeters);
        % Assign equally to each meter the sum of the buildings' usage.
        metersIncThisMeter = [metersToMultiB(m) otherMtrOnTheseBs'];
        Mdry(metersIncThisMeter) = (1/numel(metersIncThisMeter)) * sum(Bdry(bldgsOnThisMeter));
            % For case 4, record the specific usage - gallons of meter to each building.            
            for m = 1 : numel(bldgsOnThisMeter)
                for n = 1 : numel(metersIncThisMeter)
                    mbGallonsDry(metersIncThisMeter(n), bldgsOnThisMeter(m)) =  ...
                    Mdry(metersIncThisMeter(n)) / numel(bldgsOnThisMeter);
                end % for meters
            end % for buildings
    end  % if statement case 3 or 4
end  % for loop meters that serve multiple buildings

% Sum the propane cooking and clothes drying usage for each meter. This is the
% "baseline" propane usage that is assumed constant over 12 months. Annual gallons.
% Vector of length = number of buildings. Gallons.
McookDry = Mcook + Mdry;
meterPropaneCookingAndDryingUsage = McookDry;

% Also sum the cooking and drying arrays that have the gallons that each meter 
% contributes to each building. Array of size (numMeters, numBuildings).
meterBuildingGallonsArrayCookDry = mbGallonsCook + mbGallonsDry;

% Error checks. If the meter serves propane cooking/drying, and it's usage
% is less than 60% of the estimated cooking/drying usage, 
% then display an "error" message that does not stop execution.
% "It appears that the selected cooking/drying meters do not have enough
% usage on them to satisfy those loads."

for m = 1:numMeters
    pm = propaneMeters(m);
    if ((pm.IsCooking | pm.IsInUnitClothesDryer) | pm.IsCommonAreaClothesDryer) & ...
            (sum(pm.AdjustedUsageTable.AdjGallons) / pm.NumberOfYears) < (.6 * McookDry(m))
        disp("It appears that cooking/drying meter (" + m + ") " + ...
            "does not have enough usage on it to satisfy those loads.")
    end % if

end % for

% Also check if the propane cooking/drying usage assigned to propane meters within 20%
% of the estimated total propane cooking/drying usage for the buildings.
if sum(McookDry) <= .8 * (sum(Bcook) + sum(Bdry)) | ...
        sum(McookDry) >= 1.2 * (sum(Bcook) + sum(Bdry))
    disp("The propane usage for cooking and clothes drying assigned to the " + ...
        "meters varies from the estimated building usage by more than 20%. " + ...
        "Propane cooking/drying usage assigned to meters is "+McookDry+" gallons. " +...
        "Propane cooking/drying usage estimated for buildings is" + ...
        " "+ (Bcook + Bdry) +" gallons.")
end % if

%% Analyze usage for each meter

for meterIdx = 1:numMeters
    pm = propaneMeters(meterIdx);

    % Covert the annual propane usage for cooking and clothes drying to a monthly
    % vector. Constant each month.
    meterMonthlyStoveDryerUsage = (meterPropaneCookingAndDryingUsage(meterIdx)/12) .* ...
        ones(pm.NumMonthsOfData,1);
    % Add stove/dryer usage to table. Stove/dryer usage is a component of the
    % total and cannot be more than total adjusted gallons.
    pm.AdjustedUsageTable.StoveDryerGallons = ...
        min(meterMonthlyStoveDryerUsage, pm.AdjustedUsageTable.AdjGallons);

    % Subtract cooking/drying usage from adjusted gallons = variable usage
    % This is for DHW or space heating.
    variableUsage = pm.AdjustedUsageTable.AdjGallons - pm.AdjustedUsageTable.StoveDryerGallons;
    pm.AdjustedUsageTable.Variable = variableUsage;

    % If the meter serves DHW loads, calculate the DHW component using the
    % summer minimum and the sunusoidal pattern of DHW energy use.

    if pm.IsDHW
        % If the meter does serve DHW, but does not serve space heat, any
        % variable use must be allocated to DHW.
        if ~pm.IsSpaceHeat
            pm.AdjustedUsageTable.DHWGallons = pm.AdjustedUsageTable.Variable;
        else
        % The meter serves both DHW and space heat. Allocate usage accordingly.
        % Compute Minumum Adjusted Propane Therm Usage Per Year
        % For each year of data in the utility, get the lowest variable therm usage.
        % The goal here is create a vector of constant values (by year, such that
        % every 12 months in one year is a single value, but can change year by
        % year).

        % Preallocate array of nans to store minElec value into.
        minPropaneThermPerYear = nan(pm.NumMonthsOfData,1);

        % Iterate through each year of Utility Data
        for yearIdx = 1:pm.NumberOfYears
            % Create Indices for Month
            monthIndices = (1:12) + ((yearIdx-1) * 12);

            % Extract variable therm for provided months.
            monthlyAdjThermUsage = pm.AdjustedUsageTable.Variable(monthIndices);

            % Obtain the average of the two lowest values in the array.
            avgLowestTherm = mean(mink(monthlyAdjThermUsage,2));

            % Store into preallocated array via masking.
            minPropaneThermPerYear(monthIndices) = avgLowestTherm;

        end %forloop

        % Clear any remaining NaN values (though, logically, there shouldn't be
        % any)
        minPropaneThermPerYear(isnan(minPropaneThermPerYear)) = [];

        % Compute Average propaneThermOverall
        minPropaneOverallAvg = mean(minPropaneThermPerYear,"omitmissing");

        % Set DHWGallons Values in Table
        % Compute the DHWGallons column for the AdjustedUsage table from the
        % calculated values above and the set into AdjustedTable.

        % Initialize DHWGallons Column as zeros.
        pm.AdjustedUsageTable.DHWGallons = zeros(pm.NumMonthsOfData,1);

        % Compute DHW Therm
        dhwGallons = minPropaneOverallAvg * ...
            ((1 + (pm.SeasonalAmpDHWUse/2)) + ...
            (pm.SeasonalAmpDHWUse / 2) * ...
            (cos((pm.AdjustedUsageTable.Month-1)*(pi/6))));

        % Assign to DHW gallons, noting that DHW gallons can't be greater
        % than variable gallons.
        pm.AdjustedUsageTable.DHWGallons = min(dhwGallons, ...
            pm.AdjustedUsageTable.Variable);

        end % if pm.IsSpaceHeat

    elseif ~pm.IsDHW
        pm.AdjustedUsageTable.DHWGallons = zeros(pm.NumMonthsOfData, 1);

    end % if statement DHW

    % If DHW usage has been calculated as zero, because there are months of
    % zero variable usage, and yet the meter is designated as serving DHW
    % loads, throw a non fatal message to user.
    if sum(pm.AdjustedUsageTable.DHWGallons) == 0 & pm.IsDHW
        disp("DHW usage has been calculated as zero, because there are " + ...
            "months of zero variable usage, and yet the meter is designated " + ...
            "as serving DHW loads. Check end use flags and usage data for " + ...
            "propane meter ('" + meterIdx + "')");
    end

    % If the meter serves space heating loads, the remaining usage is space
    % heat.
    if pm.IsSpaceHeat
        pm.AdjustedUsageTable.SpaceHeatGallons = pm.AdjustedUsageTable.Variable - ...
            pm.AdjustedUsageTable.DHWGallons;
    elseif ~pm.IsSpaceHeat
        pm.AdjustedUsageTable.SpaceHeatGallons = zeros(pm.NumMonthsOfData, 1);
    end % if statement space heat

    % If there is remaining usage after any cooking/drying and any DHW usage
    % have been subtracted from the total usage, and yet the meter is NOT
    % designated as serving space heat, then some usage on the meter will not
    % be accounted for. Throw a message to the user, but not a fatal error 
    % message. Allow exectution to continue.
    % if (sum(pm.AdjustedUsageTable.StoveDryerGallons) + ...
    %         sum(pm.AdjustedUsageTable.DHWGallons)) < ...
    %         sum(pm.AdjustedUsageTable.AdjGallons) & ~pm.IsSpaceHeat
    %     disp("There is remaining usage on a propane meter after any cooking/drying and " + ...
    %         "any DHW usage have been subtracted from the total usage, " + ...
    %         "which would normally be attributed to space heating, " + ...
    %         "and yet the meter is NOT designated as serving space heat, " + ...
    %         "so some usage on the meter will not be accounted for. " + ...
    %         "Check the end use flags and usage data for propane meter ('"+ meterIdx +"')")
    % end

    % Develop monthly profile of space heating propane usage based on the usage
    % that would occur in a year of average weather. Average weather is
    % defined as the average number of heating degree days to base 65F over
    % the past X years - usually the past 5 years.

    % Zero out HDD's for non-heating months
    % Base it on the heating season start/end dates for the building with the
    % highest propane meter ratio.
    % This could be more accurate in the future but is a very minor factor.

    % Find the building, of those served by this meter, with the highest propane ratio.
    [maxRatio, selectedBuilding] = max(bldgMeters(meterIdx,:) .* propaneRatios(meterIdx,:));

    % Find heating months for that building. Create month vector from start
    % to end as datetime to wrap around correctly.
    % Future work: don't count months with only 1-4 days of heating season.
    heatingMonths = util.convertMonthsToVector(...
        month(bldgs(selectedBuilding).HeatCoolSeasonStartEndDates(1)),...
        month(bldgs(selectedBuilding).HeatCoolSeasonStartEndDates(2)));

    % Create heating mask.
    heatingMask = ismember(pm.AdjustedUsageTable.Month, heatingMonths);

    % Apply mask to zero out the corresponding HDDD values in AdjustedUsageTable.
    pm.AdjustedUsageTable.HDD65(~heatingMask) = 0;

    % Calculate the heat slope for this meter. If there is no space
    % heating, it will be zero. Gallons per HDD65.
    heatSlope = sum(pm.AdjustedUsageTable.SpaceHeatGallons) / ...
        sum(pm.AdjustedUsageTable.HDD65);

    % Make monthly profile for meter.
    % Iteratively extract months from AdjustedUsageTable in month order and fill
    % into the profile.

    % Preallocate Monthly matrix of values, the first row being 1:12.
    monthlyProfile = zeros(12,5);
    monthlyProfile(:,1) = (1:12)';

    for monthIdx = 1:12
        % Get Month Mask from standard Meter table (for rowmask)
        monthMask = pm.AdjustedUsageTable.Month == monthIdx;
        numMonthsFound = sum(monthMask);

        % Extract values from Proportioned Table.
        % Since there might be only one year of data, make sure to add the
        % "1" to the sum function, summing the columns.
        eachMonthVals = sum(pm.AdjustedUsageTable{monthMask,...
            ["StoveDryerGallons","DHWGallons","SpaceHeatGallons"]}, 1) / ...
            numMonthsFound;

        % Assign via addition to MonthlyProfile
        monthlyProfile(monthIdx,2:4) = monthlyProfile(monthIdx,2:4) + ...
            eachMonthVals;

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
    % with average weather.
        normAnnualHeating = avgHDD * heatSlope;

    % Normalize Monthly Table Results
    % Add Normalized Space Heating Profile
    % Note, if there are any NaN's in the monthly table for space heat, the
    % sum of that column will be NaN, propaneHeatAdj will be NaN, and calc will
    % fail.
    propaneHeatAdj = normAnnualHeating / sum(monthlyProfile(:, 4));
    monthlyProfile(:, 4) = propaneHeatAdj * monthlyProfile(:, 4);

    % Get Total Normalized Propane Usage
    % Add up StoveDryer, DHWTherm, and SpaceHeat.
    monthlyProfile(:, 5) = sum(monthlyProfile(:, 2:4), 2, "omitmissing");

    % Clean any NaN
    monthlyProfile(isnan(monthlyProfile)) = 0;
    
    % Write monthly profile to propane meter property
    pm.MonthlyProfile = array2table(monthlyProfile,...
        "VariableNames", ["Month", "StoveDryerGallons", "DHWGallons",...
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

        pm = propaneMeters(meterIdx);

        % Preallocate AnnualUsageTable for Individual Meters
        % This table is going to have 9 columns, and R rows of numeric
        % information. The number of rows is essentially 2 + (numberOfYears).

        pm.AnnualUsageTable = table('Size', [pm.NumberOfYears+2, 9],...
            'VariableTypes', ["string", repmat("double", 1, 8)],...
            'VariableNames', ["Property", "Gallons", "AdjGallons", "HDD65",...
            "StoveDryerGallons", "DHWGallons", "SpaceHeatGallons", "Cost", "HeatSlope"]);

        pm.AnnualUsageTable.Property(1:2) = ["Average"; "Fraction Total"];

        % Compute annual values. Sum the 12 monthly values for each year of data
        for yearIdx = 1:pm.NumberOfYears
            % Compute monthly index
            monthIndices = (1:12) + ((yearIdx-1) * 12);

            % -- Assign Year (as Property)
            % Identify the 12 month period by the predominant year.
            % If each of the two years has 6 months, take the first year.
            firstTwelveMonthsYears = pm.AdjustedUsageTable.Year(monthIndices);
            [C, ia, ic] = unique(pm.AdjustedUsageTable.Year(monthIndices));
            if sum((ic == 1)) > 5
                pm.AnnualUsageTable.Property(yearIdx+2) = firstTwelveMonthsYears(1);
            else pm.AnnualUsageTable.Property(yearIdx+2) = firstTwelveMonthsYears(12);
            end % if statement

            pm.AnnualUsageTable.Property(yearIdx+2) = ...
                firstTwelveMonthsYears(1);

            % -- Assign Column Values Per Year
            % Extract and compute sums.
            % Gallons
            pm.AnnualUsageTable.Gallons(yearIdx+2) = sum(...
                pm.AdjustedUsageTable.Usage(monthIndices));

            % AdjGallons
            pm.AnnualUsageTable.AdjGallons(yearIdx+2) = sum(...
                pm.AdjustedUsageTable.AdjGallons(monthIndices));

            % HDD65
            pm.AnnualUsageTable.HDD65(yearIdx+2) = sum(...
                pm.AdjustedUsageTable.HDD65(monthIndices));

            % StoveDryerGallons
            pm.AnnualUsageTable.StoveDryerGallons(yearIdx+2) = sum(...
                pm.AdjustedUsageTable.StoveDryerGallons(monthIndices));

            % DHWGallons
            pm.AnnualUsageTable.DHWGallons(yearIdx+2) = sum(...
                pm.AdjustedUsageTable.DHWGallons(monthIndices));

            % SpaceHeatGallons
            pm.AnnualUsageTable.SpaceHeatGallons(yearIdx+2) = sum(...
                pm.AdjustedUsageTable.SpaceHeatGallons(monthIndices));

            % Cost
            pm.AnnualUsageTable.Cost(yearIdx+2) = sum(...
                pm.AdjustedUsageTable.Cost(monthIndices));

        end % for loop years

        % Calculate averages for columns and put in row 1 of meter annual usage table.
        % Add fraction of total in row 2.
        avgColNames = ["Gallons","AdjGallons", "HDD65", "StoveDryerGallons", ...
            "DHWGallons", "SpaceHeatGallons", "Cost"];

        avgColVals = mean(pm.AnnualUsageTable{3:pm.NumberOfYears+2, avgColNames}, 1);
        pm.AnnualUsageTable{1, avgColNames} = avgColVals;
        pm.AnnualUsageTable.HeatSlope([1 pm.NumberOfYears+2:end]) = ...
            pm.AnnualUsageTable.SpaceHeatGallons([1 pm.NumberOfYears+2:end]) ./ ...
            pm.AnnualUsageTable.HDD65([1 pm.NumberOfYears+2:end]);

        fracTotalColNames = ["Gallons","AdjGallons", "StoveDryerGallons", ...
            "DHWGallons", "SpaceHeatGallons"];
        fracTotalVals = pm.AnnualUsageTable{1, fracTotalColNames} / ...
            pm.AnnualUsageTable{1,"Gallons"};
        pm.AnnualUsageTable{2, fracTotalColNames} = fracTotalVals;

end % for loop meters

% Check if the meter's actual usage for some months is less than the cooking/drying
% usage assigned to it above, so that the total annual propane available for cooking/
% drying is 50% less than estimated. If so, throw a message to
% the user.

for meterIdx=1:numMeters
    if propaneMeters(meterIdx).IsCooking | propaneMeters(meterIdx).IsInUnitClothesDryer | ...
            propaneMeters(meterIdx).IsCommonAreaClothesDryer
        stoveDryerFracAdj = propaneMeters(meterIdx).AnnualUsageTable.StoveDryerGallons(1) / ...
            meterPropaneCookingAndDryingUsage(meterIdx);
        if stoveDryerFracAdj < .5 
            disp("The propane usage on meter "+ meterIdx +" that is available for")
            disp("propane stoves and/or clothes dryers is at least 50% less than the")
            disp("cooking/drying usage estimated from modeling guidelines and")
            disp("assigned to that meter.")
        end % nested if
    end % if
end % for

%% Combine meters to get annual and monthly profile tables for each building

% For each building, sum the meter annual usage tables and monthly
% profiles serving that building. Add the fraction of each meter that
% applies to the building.

for bldgIdx = 1:numBuildings

    % Create Default Table for Accumulating Statistics
    buildingUsageTbl = table('Size',[0, 8], ...
        'VariableTypes',["string",repmat("double",1, 7)],...
        'VariableNames',["Property", "MeterCount", "HDD65", "TotalGallons", ...
        "StoveDryerGallons", "DHWGallons", "SpaceHeatGallons", "Cost"]);

    % Create Default Table for Accumulating Statistics
    buildingStatsTbl = table('Size',[3, 8],...
        'VariableTypes',["string",repmat("double",1, 7)],...
        'VariableNames',["Property", "MeterCount", "HDD65", "TotalGallons", ...
        "StoveDryerGallons","DHWGallons","SpaceHeatGallons", "Cost"]);

    % Set Property Strings
    buildingStatsTbl.Property = ["Average";...
        "Fraction of Total";...
        "kBtu/ft2"];

    % Set default nans
    buildingStatsTbl{:, 2:end} = nan(3,7);

    % Create table for accumulating monthly profiles
    sumMonthlyProfiles = zeros(12,5);
    sumMonthlyProfiles(:,1) = (1:12)';

    % What meters serve this building? This is all the rows and one column
    % of the logical array for meters serving buildings ("bldgMeters").
    meters = [1:numMeters]';
    thisBldgMeters = meters(bldgMeters(:, bldgIdx));

    % Take each of the meters serving this building in turn.
    for meterIdx = 1:numel(thisBldgMeters)
        pm = propaneMeters(thisBldgMeters(meterIdx));

        % First part, take fractions of meter annual usage tables for DHW 
        % and space heat and sum. Propane meter ratio applied to this building.
        pmRatioBldg = propaneRatios(thisBldgMeters(meterIdx), bldgIdx);

        % Create a table with the fraction of meter's usage.
        fracAnnualUsageTable = pm.AnnualUsageTable;
        % Remove heating slope from table.
        fracAnnualUsageTable = removevars(fracAnnualUsageTable, "HeatSlope");

        % Add MeterCount variable to the meter's fractional usageTable and 
        % make it the second column.
        fracAnnualUsageTable.MeterCount = ones(pm.NumberOfYears+2, 1);
        fracAnnualUsageTable = movevars(fracAnnualUsageTable, ...
            "MeterCount", 'After', "Property");

        % Remove the Gallons and AdjGallons columns from the table and
        % replace with TotalGallons which will be calculated by adding the
        % StoveDryer, DHW, and space heating components.
        fracAnnualUsageTable = removevars(fracAnnualUsageTable, ...
            ["Gallons", "AdjGallons"]);
        fracAnnualUsageTable.TotalGallons = nan(pm.NumberOfYears+2, 1);
        fracAnnualUsageTable = movevars(fracAnnualUsageTable, ...
            "TotalGallons", 'After', "HDD65");

        % For domestic hot water and space heating, assign fractions of usage to
        % building based on the building propane ratios. Default ratios are based on 
        % the conditioned square footage of the buildings.
        
        propColNames = ["DHWGallons", "SpaceHeatGallons"];
        fracAnnualUsageArray = pm.AnnualUsageTable{[1 3:end], propColNames} .* pmRatioBldg;
        fracAnnualUsageTable{[1 3:end], propColNames} = fracAnnualUsageArray;

        % Append new table underneath existing table.
        tempTable = [buildingUsageTbl; fracAnnualUsageTable];

        % Use varfun to assign new table.
        %   InputVariables: Vars to sum together.
        %   GroupingVariables: Vars to group by (ID column)
        %   Most vars are summed, but HDD's must be averaged.
        buildingUsageSumTbl = varfun(@sum, tempTable,...
            "GroupingVariables", "Property",...
            "InputVariables", ["MeterCount", "TotalGallons", "StoveDryerGallons", ...
            "DHWGallons", "SpaceHeatGallons", "Cost"]);

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
        buildingUsageSumTbl.Properties.VariableNames = ["Property",...
            "MeterCount", "TotalGallons", "StoveDryerGallons", ...
            "DHWGallons", "SpaceHeatGallons", "Cost"];
        % Mean Table
        buildingUsageAvgTbl.Properties.VariableNames = ["Property", "HDD65"];

        % Join Separated Tables together for BuildingUsageTbl
        buildingUsageTbl = join(buildingUsageSumTbl, buildingUsageAvgTbl);

        % Restore the original order of variables in the table.
        buildingUsageTbl = movevars(buildingUsageTbl, "HDD65", 'After', ...
            "MeterCount");

        % Second part, take fractions of monthly profiles and sum.
        % Create an array with a fraction of the monthly profile for the
        % columns of DHW and space heating only. Other columns filled in
        % for the building as a whole.
        fracMonthlyProfileArray = pm.MonthlyProfile{:, 3:4} * pmRatioBldg;
        % fracMonthlyProfileArray(:, 4) = sum(fracMonthlyProfileArray(:, :), 2);
        sumMonthlyProfiles(:, 3:4) = sumMonthlyProfiles(:, 3:4) + fracMonthlyProfileArray;

    end  % for loop meters line 746

    % Building usage for DHW and space heating has been set by fraction of
    % meter usage to each building. Set cooking/drying for each building as
    % calculated by modeling guidelines in lines 53-106. Set total usage and
    % cost and heating slope.
    
    % Cooking and drying usage for building as calculated above.
    % For rows with multiple meters, multiply the annual cook/dry usage by
    % the minimum of the meter count and the number of meters serving
    % cooking/drying.
    % For each year of meter data.
    buildingUsageTbl{1:end-2, "StoveDryerGallons"} = ...
        bldgsAnnualPropaneCookDryUsage(bldgIdx) * ones(numel(buildingUsageTbl.Property)-2, 1) .* ...
        min(buildingUsageTbl{1:end-2, "MeterCount"}, sum([stoveUsageFlags]));
    % For the average row.
    buildingUsageTbl{end-1, "StoveDryerGallons"} = ...
        bldgsAnnualPropaneCookDryUsage(bldgIdx);

    % Total usage for building is sum of StoveDryer, DHW, and space heat.
    buildingUsageTbl{1:end-1, "TotalGallons"} = ...
        sum(buildingUsageTbl{1:end-1, ["StoveDryerGallons", "DHWGallons", ...
        "SpaceHeatGallons"]}, 2);
    
    % Cost. Determine the average unit cost for propane from the average 
    % row of each meter's annual usage table. Weighted by the amount of use
    % on the meter.
    for meterIdx = 1:numel(thisBldgMeters)
        unitCostPropane(meterIdx) = propaneMeters(meterIdx).AnnualUsageTable.Cost(1) ...
            / propaneMeters(meterIdx).AnnualUsageTable.AdjGallons(1);
        totalUseMeters(meterIdx) = propaneMeters(meterIdx).AnnualUsageTable.AdjGallons(1);
    end % for loop unit cost
    avgUnitCostPropane = sum((unitCostPropane .* totalUseMeters)) / sum(totalUseMeters);

    % Determine the cost of propane for each year and for the average year.
    buildingUsageTbl{1:end-1, "Cost"} = ...
        buildingUsageTbl{1:end-1, "TotalGallons"} * avgUnitCostPropane;

    % Add heating slope.
    buildingUsageTbl.HeatSlope = nan(numel(buildingUsageTbl.Property), 1);
    buildingUsageTbl.HeatSlope(1:end-1) = ...
        buildingUsageTbl.SpaceHeatGallons(1:end-1) ./ ...
        buildingUsageTbl.HDD65(1:end-1);
    
    % Set up the 2 additional statistics rows of the annual usage table.
    % 1 average usage - already have, 2 fraction of total, 3 kBtu/ft2 .

    % The fraction of total usage for each component, in the average row. 
    % Set up names of proportional columns.
    propColNames = ["TotalGallons", "StoveDryerGallons", "DHWGallons", "SpaceHeatGallons"];
    buildingUsageTbl{end, propColNames} = buildingUsageTbl{end-1, propColNames} / ...
        buildingUsageTbl.TotalGallons(end-1);

    % The third stats row is kBtu/ft2 area (gross conditioned area in square feet).
    % Set up name of area columns.
    areaColNames = ["TotalGallons", "StoveDryerGallons", "DHWGallons", "SpaceHeatGallons"];

    % Make a temporary table for added row.
    kBtuFt2Row = table('Size',[1, 9], ...
        'VariableTypes',["string", repmat("double", 1, 8)],...
        'VariableNames',["Property", "MeterCount", "HDD65", "TotalGallons", ...
        "StoveDryerGallons", "DHWGallons", "SpaceHeatGallons", "Cost", "HeatSlope"]);
    kBtuFt2Row.Property(1) = ["kBtu/ft2"];
    kBtuFt2Row{1, areaColNames} = buildingUsageTbl{end-1, areaColNames} * ...
        91500 / 1000 / bldgs(bldgIdx).GrossConditionedArea_ft2;

    % Construct the final version of the building usage table with the rows
    % arranged in a logical manner.
    buildingUsageTbl = [buildingUsageTbl(end-1:end, :); ...
        kBtuFt2Row; buildingUsageTbl(1:end-2, :)];
   
    % Set the heat slope for the average row. Gallons/HDD65.
    buildingUsageTbl.HeatSlope(1) = buildingUsageTbl.SpaceHeatGallons(1) /...
        buildingUsageTbl.HDD65(1);
     
    % Write the annual usage table and monthly profile for the building into
    % its allocated properties
    bldgs(bldgIdx).AnnualPropaneUsageTable = buildingUsageTbl;

    % Complete the monthly profile by adding cook/dry and total usage.
    bldgMonthlyProfile = array2table(sumMonthlyProfiles, "VariableNames", ...
        ["Month", "StoveDryerGallons", "DHWGallons", "SpaceHeatGallons", "Total"]);
    bldgMonthlyProfile.StoveDryerGallons = bldgsAnnualPropaneCookDryUsage(bldgIdx) * ...
        ones(12, 1) / 12;
    bldgMonthlyProfile.Total = sum(bldgMonthlyProfile{:, 2:4}, 2);
    bldgs(bldgIdx).MonthlyPropaneProfile = bldgMonthlyProfile;

end % building loop line 421

end %function


