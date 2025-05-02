function updateAdjustedUsageTable(obj,ddTable)
%UPDATEADJUSTEDUSAGETABLE Update AdjustedUsageTable for utility based on 
% containing site or building.
%   The usage table is updated with Site-level information.

%% Arguments Block
% Confirm input arguments
arguments
    % obj: Self-referential Gas utility object.
    obj (1,1) ece.Gas

    % ddTable: Degree days table for corresponding container of utility.
    ddTable table

end %argblock

%% Compute Minumum Adjusted Gas Therm Usage Per Year
% For each year of data in the utility, get the lowest adjTherm usage.
% The goal here is create a vector of constant values (by year, such that 
% every 12 months in one year is a single value, but can change year by 
% year).

% Preallocate array of nans to store minElec value into.
minGasThermPerYear = nan(obj.NumMonthsOfData,1);

% Iterate through each year of Utility Data
for yearIdx = 1:obj.NumberOfYears
    % Create Indices for Month
    monthIndices = (1:12) + ((yearIdx-1) * 12);

    % Extract adjusted therm for provided months.
    monthlyAdjThermUsage = obj.AdjustedUsageTable.AdjTherms(monthIndices);

    % Obtain the average of the two lowest values in the array.
    avgLowestTherm = mean(mink(monthlyAdjThermUsage,2));

    % Store into preallocated array via masking.
    minGasThermPerYear(monthIndices) = avgLowestTherm;

end %forloop

% Clear any remaining NaN values (though, logically, there shouldn't be
% any)
minGasThermPerYear(isnan(minGasThermPerYear)) = [];

% Compute Average gasThermOverall
minGasOverallAvg = mean(minGasThermPerYear,"omitmissing");

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

    % Append Rows to Usage Table
    obj.AdjustedUsageTable.HDD65(monthIdx) = sumHDD65;

end %forloop (monthIdx)


%% Set DHWTherms Values in Table
% Compute the DHWTherms column for the AdjustedUsage table from the 
% calculated values above and the set into AdjustedTable.

% Initialize DHWTherms Column as zeros.
obj.AdjustedUsageTable.DHWTherms = zeros(obj.NumMonthsOfData,1);

% Check if Gas meter is used for DHW to calculate full DHWTherms.
if (obj.IsDHW)
    % Compute DHW Therm
    dhwTherms = minGasOverallAvg * ...
        ((1 + (obj.SeasonalAmpDHWUse/2)) + ...
        (obj.SeasonalAmpDHWUse / 2) * ...
        (cos((obj.AdjustedUsageTable.Month-1)*(pi/6))));

    % Assign to Therms
    obj.AdjustedUsageTable.DHWTherms = dhwTherms;

end %endif

end %function

