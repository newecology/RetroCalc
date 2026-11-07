function analyzeWater(bldgs, waterMeters, waterRatios)
%% Arguments Block
arguments
bldgs (:,1) ece.Building
waterMeters (:,1) ece.Water
waterRatios (:,:) double
end %argblock

%% Set Up Parameters
numMeters = length(waterMeters);
numBuildings = length(bldgs);

% Logical matrix: rows = meters, cols = buildings.
bldgMeters = waterRatios > 0;

%% Iterate Through Each Building
for bldgIdx = 1:numBuildings

meters = (1:numMeters)';
thisBldgMeters = meters(bldgMeters(:, bldgIdx));

% Create Default Table for Accumulating Meter Results
buildingUsageTbl = table('Size',[0,9],...
'VariableTypes',["string", repmat("double", 1, 8)],...
'VariableNames',["Property", "MeterCount", "Gallons", "AdjGallons", "IrrigationGals",...
"CoolingTowerGals", "OtherGals", "ResidentialGals", "Cost"]);
numBldgUsageVariables = 9;

buildingStatsTbl = table('Size',[2,9],...
'VariableTypes',["string",repmat("double",1,8)],...
'VariableNames',["Property","MeterCount","Gallons","AdjGallons", ...
  "IrrigationGals","CoolingTowerGals","OtherGals", ...
  "ResidentialGals","Cost"]);
buildingStatsTbl.Property = ["Average"; "Fraction of Total"];
buildingStatsTbl{:,2:end} = nan(2,8);

%% Annual Table — Per Meter
for meterIdx = 1:numel(thisBldgMeters)
wm = waterMeters(thisBldgMeters(meterIdx));
wmProp = waterRatios(thisBldgMeters(meterIdx), bldgIdx);

propAdjustedUsageTable = wm.AdjustedUsageTable(:,...
  ["Usage","Cost","AdjGallons","IrrigationGals", ...
  "CoolingTowerGals","OtherGals","ResidentialGals"]);
propAdjustedUsageTable{:,:} = propAdjustedUsageTable{:,:} .* wmProp;

nanMatrix = nan(wm.NumberOfYears, numBldgUsageVariables);
meterUsageTbl = array2table(nanMatrix,...
  "VariableNames",["Property","MeterCount","Gallons","AdjGallons", ...
  "IrrigationGals","CoolingTowerGals","OtherGals", ...
  "ResidentialGals","Cost"]);

for yearIdx = 1:wm.NumberOfYears
  monthIndices = (1:12) + ((yearIdx-1) * 12);
  firstTwelveMonthsYears = wm.AdjustedUsageTable.Year(monthIndices);
  meterUsageTbl.Property(yearIdx) = firstTwelveMonthsYears(1);
  meterUsageTbl.MeterCount(yearIdx) = 1;
  meterUsageTbl.Gallons(yearIdx)        = sum(propAdjustedUsageTable.Usage(monthIndices));
  meterUsageTbl.AdjGallons(yearIdx)     = sum(propAdjustedUsageTable.AdjGallons(monthIndices));
  meterUsageTbl.IrrigationGals(yearIdx) = sum(propAdjustedUsageTable.IrrigationGals(monthIndices));
  meterUsageTbl.CoolingTowerGals(yearIdx)= sum(propAdjustedUsageTable.CoolingTowerGals(monthIndices));
  meterUsageTbl.OtherGals(yearIdx)      = sum(propAdjustedUsageTable.OtherGals(monthIndices));
  meterUsageTbl.ResidentialGals(yearIdx)= sum(propAdjustedUsageTable.ResidentialGals(monthIndices));
  meterUsageTbl.Cost(yearIdx)           = sum(propAdjustedUsageTable.Cost(monthIndices));
end %forloop years

tempTable = [buildingUsageTbl; meterUsageTbl];
buildingUsageTbl = varfun(@sum, tempTable,...
  "GroupingVariables","Property",...
  "InputVariables",["MeterCount", "Gallons", "AdjGallons", ...
  "IrrigationGals", "CoolingTowerGals", "OtherGals", ...
  "ResidentialGals", "Cost"]);
buildingUsageTbl.GroupCount = [];
buildingUsageTbl.Properties.VariableNames = meterUsageTbl.Properties.VariableNames;

avgColNames = ["Gallons", "AdjGallons", "IrrigationGals", ...
  "CoolingTowerGals", "OtherGals", "ResidentialGals", "Cost"];
avgColVals = mean(meterUsageTbl{1:wm.NumberOfYears, avgColNames}, 1);
buildingStatsTbl{1, avgColNames} = sum([buildingStatsTbl{1, avgColNames}; avgColVals], 1, "omitmissing");

end %forloop meters

%% Fraction of Total Row
propColNames = ["AdjGallons", "IrrigationGals", "CoolingTowerGals", "OtherGals", "ResidentialGals"];
buildingStatsTbl{2, propColNames} = buildingStatsTbl{1, propColNames} ./ buildingStatsTbl.Gallons(1);

bldgs(bldgIdx).AnnualWaterUsageTable = [buildingStatsTbl; buildingUsageTbl];

%% Monthly Profile — Per Meter
monthlyProfile = zeros(12,6);
monthlyProfile(:,1) = (1:12)';

for meterIdx = 1:numel(thisBldgMeters)
wm = waterMeters(thisBldgMeters(meterIdx));
wmProp = waterRatios(thisBldgMeters(meterIdx), bldgIdx);

propAdjustedUsageTable = wm.AdjustedUsageTable(:,...
  ["AdjGallons","IrrigationGals","CoolingTowerGals","OtherGals","ResidentialGals"]);
propAdjustedUsageTable{:,:} = propAdjustedUsageTable{:,:} .* wmProp;

for monthIdx = 1:12
  monthMask = wm.AdjustedUsageTable.Month == monthIdx;
  numMonthsFound = sum(monthMask);
  gallonVals = sum(propAdjustedUsageTable{monthMask,...
      ["AdjGallons","IrrigationGals","CoolingTowerGals","OtherGals","ResidentialGals"]},1) / ...
      numMonthsFound;
  monthlyProfile(monthIdx,2:6) = monthlyProfile(monthIdx,2:6) + gallonVals;
end %forloop months

end %forloop meters

bldgs(bldgIdx).MonthlyWaterProfile = array2table(monthlyProfile,...
"VariableNames",["Month","IrrigationGals",...
"CoolingTowerGals","OtherUseGals","ResidentialGals","TotalGallons"]);

end %forloop buildings

end %function