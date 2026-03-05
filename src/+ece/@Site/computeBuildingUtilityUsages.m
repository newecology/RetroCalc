function computeBuildingUtilityUsages(site)
%COMPUTEBUILDINGUTILITYUSAGES Method to compute the Building and Utility
%usages within the Site object.
%   This method processes both the Utilities (across all Utility Types) and
%   Buildings to set up each utilities' AdjustedUsageTables and each
%   Buildings' proportional annual and monthly usages.

%% Argument Block
arguments
    % site: Self-referencing Site object.
    site (1,1) ece.Site
end %argblock

% NOTE: Stop this from happening unless the Site has Meters AND
% Buildings.

%% Obtain Properties
% Extract site properties into vars for easier reference.
histDDTable = site.Location.HistoricalDDTable;

%% Process Electricity Utility and Building Usages
% Set up adjusted use table for each electricity utility, and then process
% each Building's proportional AnnualElectricityUsageTable and
% MonthlyProfile.

% Process Utility Usage Tables
for em = 1:numel(site.ElectricMeters)
    site.ElectricMeters(em).createAnalysisTable(histDDTable);
end %forloop (electric meters)

% Analyze the utility data to break out end uses where possible and develop 
% usage for each building.
numYearsToAvg = 10;
site.Buildings.analyzeElectricity(site.ElectricMeters, site.BuildingElecRatios, ...
    histDDTable, numYearsToAvg);

%% Process Gas Utility and Building Usages
% Set up adjusted use table for each gas utility, and then process each
% Building's proportional AnnualGasUsageTable and MonthlyProfile.

% Process Utility Usage Tables
for gm = 1:numel(site.GasMeters)
    site.GasMeters(gm).createAnalysisTable(histDDTable);
end %forloop (gas meters)

% Analyze the utility data to break out end uses where possible and develop 
% usage for each building.
numYearsToAvg = 5;
site.Buildings.analyzeGas(site.GasMeters, site.BuildingGasRatios, ...
    histDDTable, numYearsToAvg);

%% Process Water Utility and Building Usages
% Set up adjusted use table for each water utility, and then process
% each Building's proportional AnnualWaterUsageTable and
% MonthlyProfile.

% Process Utility Usage Tables
for wm = 1:numel(site.WaterMeters)
    site.WaterMeters(wm).updateAdjustedUsageTable();
end %forloop (water meters)

% Process Building Usage Tables
for bd = 1:site.NumBuildings
    % Annual Usage Table
    site.Buildings(bd).analyzeWater(...
        site.WaterMeters,...
        site.BuildingWaterRatios(:,bd));
    % 
    % % Monthly Profile
    % site.Buildings(bd).createWaterMonthlyProfile(...
    %     site.WaterMeters,...
    %     site.BuildingWaterRatios(:,bd));

end %forloop (buildings)

%% Process Oil Utility and Building Usages
% Set up adjusted use table for each oil utility, and then process each
% Building's proportional AnnualOilUsageTable and MonthlyProfile.

% Process Utility Usage Tables
for gm = 1:numel(site.OilMeters)
    site.OilMeters(gm).createAnalysisTable(histDDTable);
end %forloop (gas meters)

% Analyze the utility data to break out end uses where possible and develop 
% usage for each building.
if (numel(site.OilMeters)>0)
   site.Buildings.analyzeOil(...
      site.OilMeters, ...
      site.BuildingOilRatios, ...
      histDDTable, ...
      numYearsToAvg);
end % end if

%% Process Propane Utility and Building Usages
% Set up adjusted use table for each propane utility, and then process each
% Building's AnnualPropaneUsageTable and MonthlyProfile.

% Process Utility Usage Tables
for pm = 1:numel(site.PropaneMeters)
    site.PropaneMeters(pm).createAnalysisTable(histDDTable);
end %forloop (gas meters)

% Analyze the utility data to break out end uses where possible and develop 
% usage for each building.
numYearsToAvg = 5;
if (numel(site.OilMeters)>0)
   site.Buildings.analyzePropane(site.PropaneMeters, site.BuildingPropaneRatios, ...
    histDDTable, numYearsToAvg);
end % end if
end %function

