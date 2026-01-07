function updateAdjustedUsageTable(obj)
%UPDATEADJUSTEDUSAGETABLE Update AdjustedUsageTable for utility based on 
% containing site or building.
%   The usage table is updated with Site-level information.

%% Arguments Block
% Confirm input arguments
arguments
    % obj: Self-referential Water utility object.
    obj (1,1) ece.Water

end %argblock

%% Add Logic to Divide Gallon Type
% If only one flag is checked for either of the below two, then it will be
% assigned to that column.

% If there is more than one flag set in addition to either of the below,
% throw warning.

%% Calculate Monthly Distribution for Irrigation and Cooling
% Use SummerWaterDistribution for Irrigation and Cooling.
irrigationMonthly = obj.IrrigationGal .* obj.SummerWaterDist;
coolTowerMonthly = obj.CoolingTowerGal .* obj.SummerWaterDist;

% All other water is just divided evenly over the 12 months.
otherMonthly = (obj.OtherGal/12) .* ones(12,1);

%% Align Irrigation and Cooling by Month
% AdjustedUsageTable months may not be in the same order as the intended
% distribution gallons, so arrange the monthly distribution to correspond with 
% the starting month of the data.

startMonth = obj.AdjustedUsageTable.Month(1);
irrigationMonthlyThisMeter = irrigationMonthly([startMonth:end 1:startMonth-1]);
coolTowerMonthlyThisMeter = coolTowerMonthly([startMonth:end 1:startMonth-1]);

%% Append Monthly Gallon Usages to Table
% Transpose row to column vector and add N copies to table, where N is the
% number of years of data in the utility.

% Irrigation Gals
obj.AdjustedUsageTable.IrrigationGals = repmat(irrigationMonthlyThisMeter,...
    obj.NumberOfYears, 1);
% CoolingTowerGals
obj.AdjustedUsageTable.CoolingTowerGals = repmat(coolTowerMonthlyThisMeter,...
    obj.NumberOfYears, 1);
% OtherGals
obj.AdjustedUsageTable.OtherGals = repmat(otherMonthly,...
    obj.NumberOfYears, 1);

%% Compute and Append Residential Gallons
% Water that is not used for Irrigation, Cooling, or Other is use for
% normal residential purposes.
residentialGallons = obj.AdjustedUsageTable.AdjGallons - ...
    obj.AdjustedUsageTable.IrrigationGals - ...
    obj.AdjustedUsageTable.CoolingTowerGals - ...
    obj.AdjustedUsageTable.OtherGals;

% Create error message if residential gallons is less than zero.

% Add to Table Column
obj.AdjustedUsageTable.ResidentialGals = residentialGallons;

end %function

