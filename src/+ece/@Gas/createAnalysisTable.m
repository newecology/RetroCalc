function createAnalysisTable(obj, ddTable)
% createAnalysisTable. Update AdjustedUsageTable for utility based on 
% containing site or building.
% The usage table is updated with degree days for each billing period.

%% Arguments Block
% Confirm input arguments
arguments
    % obj: Self-referential Gas utility object.
    obj (1,1) ece.Gas

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
    histDDMask = ddTable.Date >= dateStart & ddTable.Date <= dateEnd;

    % Calculate HistDD Value sums for HDD65/CDD70
    sumHDD65 = sum(ddTable.HDD65(histDDMask),"omitmissing");

    % Append Rows to Usage Table
    obj.AdjustedUsageTable.HDD65(monthIdx) = sumHDD65;

end %forloop (monthIdx)


end %function

