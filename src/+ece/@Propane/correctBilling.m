function correctBilling(propaneUtil)
% CORRECTBILLING Method to assign integer month numbers to the AdjustedUsageTable
% and to have even periods of billing across the dates of entry.
% This corrects for uneven billing periods which would skew the analysis. 
% The dates are adjusted so usages are given across 12 periods of 
% equal duration in each year. Usage per day times 365/12 for each billing period.

%% Arguments
% Define input arguments
arguments
    % g: Self-referential Propane object.
    propaneUtil (1,1) ece.Propane
end %argblock

%% Add Days, Months, Year Columns to Table
% Convert the date range given in each row to a row of numerical DMY
% representations.
% Days Value
deltaDays = days(propaneUtil.AdjustedUsageTable.EndDate - propaneUtil.AdjustedUsageTable.StartDate);
propaneUtil.AdjustedUsageTable.Days = deltaDays + 1;

%% Correct Months with Irregular Billing
% Assign a month number (integer 1 to 12) to each billing period for the calendar
% month that is most represented in the billing period. Since billing periods are
% irregular and can be anywhere from 25 to 36 days, or even fall outside
% that range, and since the billing period can break across calendar months
% evenly, such as Jun 15 to July 15, the following method is used.

% Consider the first and last months of the utility data set.
% Where a billing period spans calendar months, find the fraction of the
% calendar month for the first and second part of the billing period.
% If the largest month fraction is from the first billing period, count
% forwards from there, assigning a month number to each billing period. 
% If the largest month fraction is from the last billing period, count 
% backwards from there.

firstMonthFrac1 = 0;
firstMonthFrac2 = 0;
lastMonthFrac1 = 0;
lastMonthFrac2 = 0;
monthDays = [31 28 31 30 31 30 31 31 30 31 30 31];
numMonths = numel(propaneUtil.AdjustedUsageTable.StartDate);

% Month and day for the first and last month start and end dates.
firstStartDateM = month(propaneUtil.AdjustedUsageTable.StartDate(1));
firstStartDateD = day(propaneUtil.AdjustedUsageTable.StartDate(1));
firstEndDateM = month(propaneUtil.AdjustedUsageTable.EndDate(1));
firstEndDateD = day(propaneUtil.AdjustedUsageTable.EndDate(1));

lastStartDateM = month(propaneUtil.AdjustedUsageTable.StartDate(end));
lastStartDateD = day(propaneUtil.AdjustedUsageTable.StartDate(end));
lastEndDateM = month(propaneUtil.AdjustedUsageTable.EndDate(end));
lastEndDateD = day(propaneUtil.AdjustedUsageTable.EndDate(end));

% Find calendar month fractions for the first and last months of the data set.
if firstStartDateM == firstEndDateM
    firstMonthFrac1 = 1;
    firstMonthFrac2 = 0;
else firstMonthFrac1 = 1 - (firstStartDateD) / monthDays(firstStartDateM);
    firstMonthFrac2 = firstEndDateD / monthDays(firstEndDateM);
end

if lastStartDateM == lastEndDateM
    lastMonthFrac1 = 1;
    lastMonthFrac2 = 0;
else lastMonthFrac1 = 1 - (lastStartDateD) / monthDays(lastStartDateM);
    lastMonthFrac2 = lastEndDateD / monthDays(lastEndDateM);
end

% Find the largest month fraction.
[maxFrac, index] = max([firstMonthFrac1, firstMonthFrac2, lastMonthFrac1, lastMonthFrac2]);

% If the largest month fraction is from the first billing period, count
% forwards from there. If the largest month fraction is from the last billing
% period, count backwards from there.
if index == 1 | index == 2          % base month numbers on first month
    if index == 1                  
        firstMonthNumber =  firstStartDateM;
    elseif index == 2
        firstMonthNumber =  firstEndDateM;
    end
% Count forwards from first month.
monthSequence = firstMonthNumber:(numMonths + firstMonthNumber-1);
end

if index == 3 | index == 4          % base month numbers on last month
    if index == 3              
        lastMonthNumber = lastStartDateM;
    else index == 4
        lastMonthNumber = lastEndDateM;
    end
% Count backwards from last month.
monthSequence = lastMonthNumber + 1:(numMonths + lastMonthNumber);
end

% Sequence month numbers as 1 to 12.
a = monthSequence < 13;
b = monthSequence > 12 & monthSequence < 25;
c = monthSequence > 24 & monthSequence < 37;
d = monthSequence > 36 & monthSequence < 49;
monthSequence(a) = monthSequence(a); 
monthSequence(b) = monthSequence(b)-12; 
monthSequence(c) = monthSequence(c)-24;
monthSequence(d) = monthSequence(d)-36;

% Write assigned month number to table.
propaneUtil.AdjustedUsageTable.Month = monthSequence';

% Years Value
yearVals = year(propaneUtil.AdjustedUsageTable.StartDate + days(16));
propaneUtil.AdjustedUsageTable.Year = yearVals;

%% Adjust gallons Values
% The gallons values need to be proportioned based on the new times. Put this
% into a new column of adjustedGallons, scaled to months. This value may not
% perfectly match the total value of original Gallons, so the adjusted values
% are scaled up or down to ensure they sum to the same total gallons as before.

% Convert to a monthly form of adjusted gallons.
propaneUtil.AdjustedUsageTable.AdjGallons = ...
    (propaneUtil.AdjustedUsageTable.Usage ./ propaneUtil.AdjustedUsageTable.Days) * ...
    (365/12);

% Compute the fractional adjustment needed to map sum of AdjGallons back
% to total real Gallons.
fracAdj = sum(propaneUtil.AdjustedUsageTable.AdjGallons) / ...
    sum(propaneUtil.AdjustedUsageTable.Usage);

% Apply adjustment to AdjkWh to make the total sum usage the same.
propaneUtil.AdjustedUsageTable.AdjGallons = ...
    propaneUtil.AdjustedUsageTable.AdjGallons / fracAdj;

end %function