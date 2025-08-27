function correctBilling(waterUtil)
% CORRECTBILLING Method to normalize the AdjustedUsageTable to have even periods of
% billing across the dates of entry.
%  This method corrects for uneven billing periods which would skew the 
%  analysis. The dates are adjust so usages are given across 12 periods of 
%  equal duration in each year. 
%  Usage per day times 365/12 for each billing period.
% TODO: Does this need some logic to check if this actually needs to
%       happen?
%       Why is days(15) hardcoded into here?
%       What is going on with the conditional? Why is it -1 + 2, and not
%       +1?

%% Arguments
% Define input arguments
arguments
    % w: Self-referential Water object.
    waterUtil (1,1) ece.Water
end %argblock

%% Add Days, Months, Year Columns to Table
% Convert the date range given in each row to a row of numerical DMY
% representations.
% Days Value
deltaDays = days(waterUtil.AdjustedUsageTable.EndDate - waterUtil.AdjustedUsageTable.StartDate);
waterUtil.AdjustedUsageTable.Days = deltaDays + 1;

% Months Value
monthVals = month(waterUtil.AdjustedUsageTable.StartDate + days(15));
waterUtil.AdjustedUsageTable.Month = monthVals;

% Years Value
yearVals = year(waterUtil.AdjustedUsageTable.StartDate + days(15));
waterUtil.AdjustedUsageTable.Year = yearVals;


%% Correct Months with Irregular Billing
% Do something.

% Iterate through all months after the first to adjust month value.
for mIdx = 2:waterUtil.NumMonthsOfData
    % -- Get Logical Flags
    % Current month matches last previous month in table.
    isCurrentMonthSameAsLastMonth = ...
        waterUtil.AdjustedUsageTable.Month(mIdx) == waterUtil.AdjustedUsageTable.Month(mIdx-1);
    % Current month matches next month, but in a weird way?
    isCurrentMonthSameAsNextMonth = ...
        waterUtil.AdjustedUsageTable.Month(mIdx) == waterUtil.AdjustedUsageTable.Month(mIdx-1) + 2;

    % -- Perform Month Value Updates
    % Check conditions above in order to update current month value.
    if isCurrentMonthSameAsLastMonth
        % Current month matches last month, push current month forward one.
        waterUtil.AdjustedUsageTable.Month(mIdx) = waterUtil.AdjustedUsageTable.Month(mIdx) + 1;

    elseif isCurrentMonthSameAsNextMonth
        % Current month matches next month, bring current month back one.
        waterUtil.AdjustedUsageTable.Month(mIdx) = waterUtil.AdjustedUsageTable.Month(mIdx) - 1;

    end %endif

end %forloop (mIdx)

%% Adjust Gallons Values
% The gal values need to be proportioned based on the new times. Put this
% into a new column of adjustedGals, scaled to months. This value may not
% perfectly match the total value of original kWh, so the adjusted values
% are scaled up or down to ensure they sum to the same total Gal as before.

% Convert to a monthly form of asjusted kWh.
waterUtil.AdjustedUsageTable.AdjGallons = (waterUtil.AdjustedUsageTable.Usage ./ waterUtil.AdjustedUsageTable.Days) * (365/12);

% Compute the fractional adjustment needed to map sum of Adjusted Gals back
% to total real Gals.
fracAdj = sum(waterUtil.AdjustedUsageTable.AdjGallons) / sum(waterUtil.AdjustedUsageTable.Usage);

% Apply adjustment to AdjkWh to make the values the same.
waterUtil.AdjustedUsageTable.AdjGallons = waterUtil.AdjustedUsageTable.AdjGallons / fracAdj;

end %function