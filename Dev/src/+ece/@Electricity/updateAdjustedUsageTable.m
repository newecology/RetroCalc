function updateAdjustedUsageTable(obj,ddTable)
%UPDATEADJUSTEDUSAGETABLE Update AdjustedUsageTable for utility based on 
% containing site or building.
%   The usage table is updated with Site-level information.

%% Arguments Block
% Confirm input arguments
arguments
    % obj: Self-referential Electricity utility object.
    obj (1,1) ece.Electricity

    % ddTable: Degree days table for corresponding container of utility.
    ddTable table

end %argblock

%% Condense Historical Degree Days into Usage Table
% For each month in the AdjustedUsageTable capture the rows in the HDD table that
% fall in-between the start and end times and add the sum of the HDD values
% to the usage table.
for monthIdx = 1:obj.NumMonthsOfData
    % Extract Start and End Dates from Utility
    dateStart = obj.AdjustedUsageTable.StartDate(monthIdx);
    dateEnd = obj.AdjustedUsageTable.EndDate(monthIdx);

    % Create Mask for values in HDD to sum up.
    histDDMask = dateStart <= ddTable.Date & ddTable.Date >= dateEnd;

    % Calculate HistDD Value sums for HDD65/CDD70
    sumHDD65 = sum(ddTable.HDD65(histDDMask),"omitmissing");
    sumCDD70 = sum(ddTable.CDD70(histDDMask),"omitmissing");

    % Append Rows to Usage Table
    obj.AdjustedUsageTable.HDD65(monthIdx) = sumHDD65;
    obj.AdjustedUsageTable.CDD70(monthIdx) = sumCDD70;

end %forloop (monthIdx)

%% Zero Out Summer and Winter Months
% For BOSTON, we specifically want to zero out the values in the HDD and
% CDD during the summer and winter months, respectively. This reflects the
% "reasonableness" that you wouldn't run heating in the summer or cooling
% in the winter.

% Define Summer and Winter month (by month index)
summerMonths = [6,7,8];
winterMonths = [11,12,1,2,3,4];

% Create summer and winter mask.
summerMask = ismember(obj.AdjustedUsageTable.Month,summerMonths);
winterMask = ismember(obj.AdjustedUsageTable.Month,winterMonths);

% Apply mask to zero out the corresponding HDD/CDD values in AdjustedUsageTable.
obj.AdjustedUsageTable.HDD65(summerMask) = 0;
obj.AdjustedUsageTable.CDD70(winterMask) = 0;


%% Calculate Percent Days for Heating/Cooling
% Using the flags for how the heating and cooling are used, we will further
% create columns in the AdjustedUsageTable to adjust percentages.

% Precalculate basis vectors; zero arrays are mostly used anytime at least
% one flag is false.
zeroVec = zeros(height(obj.AdjustedUsageTable),1);

% Pre-create the PercentHeat/Cool columns for posterity.
obj.AdjustedUsageTable.PercentHeat = zeroVec;
obj.AdjustedUsageTable.PercentCool = zeroVec;

if (obj.IsSpaceHeat && obj.IsCooling)
    % -- Utility is used for both heating and cooling.
    % Compute Proportional Heating and cooling vectors.
    totalHeatCool = (obj.AdjustedUsageTable.HDD65 + obj.AdjustedUsageTable.CDD70);
    propHeating = obj.AdjustedUsageTable.HDD65 / totalHeatCool;
    propCooling = obj.AdjustedUsageTable.CDD70 / totalHeatCool;

    % Assign Columns to Table
    obj.AdjustedUsageTable.PercentHeat = propHeating;
    obj.AdjustedUsageTable.PercentCool = propCooling;

    % CALLOUT: This logic is embedded in the minElecMoYr function, discuss
    % with Henry/Sank.
    obj.ElecBaseAdj = 1;

elseif (~obj.IsSpaceHeat && obj.IsCooling)
    % -- Utility is used for only cooling.
    % Retain Zeros in PercentHeat column.

    % Set Ones to Cooling Column anywhere it wouldn't be the winter mask.
    obj.AdjustedUsageTable.PercentCool(~winterMask) = 1;

elseif (obj.IsSpaceHeat && ~obj.IsCooling)
    % Utility is used for only heating.
    % Retain Zeros in PercentCool column.

    % Set Ones to Heat Column anywhere it wouldn't be the summer mask.
    obj.AdjustedUsageTable.PercentHeat(~summerMask) = 1;

else
    % -- Utility is used for neither heating nor cooling.
    % Do nothing as columns are already zeroed out.

end %endif (Heat/Cool determination)

%% Compute Minumum Adjusted kWh Usage Per Year
% For each year of data in the utility, get the lowest adjkWh usage.
% The goal here is create a vector of constant values (by year, such that 
% every 12 months in one year is a single value, but can change year by 
% year).

% Preallocate array of nans to store minElec value into.
minElecKwHPerYear = nan(obj.NumMonthsOfData,1);

% Iterate through each year of Utility Data
for yearIdx = 1:obj.NumberOfYears
    % Create Indices for Month
    monthIndices = (1:12) + ((yearIdx-1) * 12);

    % Extract adjusted kWh for provided months.
    monthlyAKWHUsage = obj.AdjustedUsageTable.AdjkWh(monthIndices);

    % Obtain the average of the two lowest values in the array, and then
    % multiply it by the ElecBaseAdj value.
    avgLowestKWH = mean(mink(monthlyAKWHUsage,2)) * obj.ElecBaseAdj;

    % Store into preallocated array via masking.
    minElecKwHPerYear(monthIndices) = avgLowestKWH;

end %forloop

% Clear any remaining NaN values (though, logically, there shouldn't be
% any)
minElecKwHPerYear(isnan(minElecKwHPerYear)) = [];


%% Set BaseUsage Values in Table
% Compute the Base column for the AdjustedUsage table from the calculated
% values above and the set BaseLoad Amp.

% Initialize BaseAmp from properties of utility.
baseAmp = obj.BaseElecAmplitude;
if (obj.IsDHW)
    % Add SeasonalDHWUse as applicable
    baseAmp = baseAmp + obj.SeasonalAmpDHWUse;
end %endif

% Calculate Base vector for inclusion in table
baseUsagePerMonth = minElecKwHPerYear .* ...
    ((1 + (baseAmp/2)) + ...
    (baseAmp / 2) * ...
    (cos((obj.AdjustedUsageTable.Month-1) * (pi/6))));

% Ensure that the base usage value is at most as much as the corresponding
% adjkWh amount. Essentially pick the smaller of the two options.
obj.AdjustedUsageTable.Base = min(...
    baseUsagePerMonth,obj.AdjustedUsageTable.AdjkWh);

%% Compute HVAC Usage Each Month
% Calculate the HVAC usage (can't be negative) for each month using the
% base case. This is the subtraction of the adjusted kWh and the
% just-calculated base value.

% Compute HVAC Usage (overall)
hvacUsage = (obj.AdjustedUsageTable.AdjkWh - obj.AdjustedUsageTable.Base);

% Assign to Heat/Cool Columns by proportion.
obj.AdjustedUsageTable.Heat = hvacUsage .* ...
    obj.AdjustedUsageTable.PercentHeat;
obj.AdjustedUsageTable.Cool = hvacUsage .* ...
    obj.AdjustedUsageTable.PercentCool;

%% Proportional Fixing of Usage
% If the sum of Base, Heat, and Cool columns is different from the
% correspong sum of all AdjkWh, adjust the Base, Heat, and Cool
% proportionally so the sum equals the actual value.

% Sum Adjusted and Usage
totalAdjkWh = sum(obj.AdjustedUsageTable.AdjkWh);
totalUsage = sum(obj.AdjustedUsageTable{:,["Base","Heat","Cool"]},"all");

% Convert proportionally if not equal
if ~(totalUsage == totalAdjkWh)
    % Determine ratio of usage sum to adjusted sum.
    correctRatio = totalAdjkWh/totalUsage;

    % Multiply usage vectors by correction ratio.
    obj.AdjustedUsageTable{:,["Base","Heat","Cool"]} = ...
        obj.AdjustedUsageTable{:,["Base","Heat","Cool"]} .* correctRatio;

end %endif

end %function

