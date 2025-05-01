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

%% TODO
% TODO: This ABSOLUTELY requires HistoricalDDs to be imported in all cases.
% Utilities can be imported alone, but Buildings requires all three.

%% Process Electricity Utility and Building Usages
% Set up adjusted use table for each electricity utility, and then process
% each Building's proportional AnnualElectricityUsageTable and
% MonthlyProfile.

% Process Utility Usage Tables
for em = 1:numel(site.ElectricMeters)
    site.ElectricMeters(em).updateAdjustedUsageTable(site.HistoricalDDTable);
end %forloop (electric meters)

% Process Building Usage Tables
for bd = 1:site.NumBuildings
    % Annual Usage Table
    site.Buildings(bd).createAnnualElectricityUsageTable(...
        site.ElectricMeters,...
        site.BuildingElecRatios(:,bd));

    % Monthly Profile
    site.Buildings(bd).createElectricityMonthlyProfile(...
        site.HistoricalDDTable,...
        site.ElectricMeters,...
        site.BuildingElecRatios(:,bd),...
        5);
end %forloop (buildings)


%% Process Gas Utility and Building Usages
% Set up adjusted use table for each gas utility, and then process each
% Building's proportional AnnualGasUsageTable and MonthlyProfile.

% Process Utility Usage Tables
for gm = 1:numel(site.GasMeters)
    site.GasMeters(gm).updateAdjustedUsageTable(site.HistoricalDDTable);
end %forloop (gas meters)

% Process Building Usage Tables
for bd = 1:site.NumBuildings
    % Annual Usage Table and Monthly Profile
    site.Buildings(bd).createAnnualAndMonthlyGasUsageTable(...
        site.HistoricalDDTable,...
        site.GasMeters,...
        site.BuildingGasRatios(:,bd),...
        5);

end %forloop (buildings)

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
    site.Buildings(bd).createAnnualWaterUsageTable(...
        site.WaterMeters,...
        site.BuildingWaterRatios(:,bd));

    % Monthly Profile
    site.Buildings(bd).createWaterMonthlyProfile(...
        site.WaterMeters,...
        site.BuildingWaterRatios(:,bd));

end %forloop (buildings)


end %function

