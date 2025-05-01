function createElectricityMonthlyProfile(bldg,ddTable,elecMeters,elecRatios,...
    numYearsToAvg)
%CREATEELECTRICITYMONTHLYPROFILE Create the MonthlyProfile table for
%Electric Utilities.
%   This MonthlyProfileTable is used to decribe the monthly use for a
%   utility over a year, and is created from the average monthly results
%   from a Utility's usage table.

%% Arguments Block
% Confirm input arguments
arguments
    % bldg: Self-referential Building object.
    bldg (1,1) ece.Building

    % ddTable: Degree days table for corresponding container of utility.
    ddTable table

    % elecMeters: Array of electricity meters serving building.
    elecMeters (:,1) ece.Electricity

    % elecRatios: Ratio of meter usage in building.
    elecRatios (:,1) double

    % numYearsToAvg: Number of years to average together.
    numYearsToAvg (1,1) double

end %argblock

%% Normalize Recent Actual Heating/Cooling
% Use the corresponding DD table from the containing area to pull the
% average years temperatures.

% Convert years to average to number of days (sloppily, no leap years)
numDaysToAvg = numYearsToAvg * 365;
lastXYearsIndices = (height(ddTable)+1 - numDaysToAvg) : height(ddTable);

% Obtain month values for the last x years in the dd table.
avgMonths = month(ddTable.Date(lastXYearsIndices));

% Define Summer and Winter month (by month index)
summerMonths = [7,8];
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

%% Set Up Parameters for MonthlyTable Creation
% Pull required information from the inputs to ease downstream processing.
numMeters = length(elecMeters);


% -- Create Monthly Profile
% Based off normalized annual Heat/Cool. Adds on to base usage to have a
% normalized 12-month profile for use in Level 2 calculation. Monthly
% profile starts in January and is normalized to average year weather.
%  The monthly profile is a 12 row (per month) and 5-column table.
%   Table columns are: Month, Base, Heat, Cool, and Total.

% Preallocate Monthly matrix of values, the first row being 1:12.
monthlyProfile = zeros(12,5);
monthlyProfile(:,1) = (1:12)';

%% Iterate Through Each Meter
% Each meter will be used to generate a monthly usage table, which will be
% summed together for the building's single final MonthlyProfile table.

for meterIdx = 1:numMeters
    %% Extract Loop Properties from Inputs
    % Extract meter and proportion.
    em = elecMeters(meterIdx);
    emProp = elecRatios(meterIdx);

    % Extract AdjustedUsageTable Section and Proportionalize It
    % Note: The indices pulled are columns from AdjkWh and beyond, and also
    % including the initial kWh.
    propAdjustedUsageTable = em.AdjustedUsageTable(:,...
        ["kWh","Cost","AdjkWh","Base","Heat","Cool"]);
    propAdjustedUsageTable{:,:} = propAdjustedUsageTable{:,:} .* emProp;

    % Iteratively extract months from AdjustedUsageTable in month order and ill
    % into the profile.
    for monthIdx = 1:12
        % Get Month Mask from standard Meter table (for rowmask)
        monthMask = em.AdjustedUsageTable.Month == monthIdx;
        numMonthsFound = sum(monthMask);

        % Extract Base, Heat, and Cool Values from Proportioned Table
        baseHeatCoolVals = sum(propAdjustedUsageTable{monthMask,...
            ["Base","Heat","Cool"]}) / numMonthsFound;

        % Assign via addition to MonthlyProfile
        monthlyProfile(monthIdx,2:4) = monthlyProfile(monthIdx,2:4) + ...
            baseHeatCoolVals;

    end %forloop

end %forloop

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

