function plotActualVModeledMonthlyOilUsage(obj, ax)
% plotActualVModeledMonthlyOilUsage: Method to plot the actual
% vs. Modeled monthly usage of Oil for a single year.
arguments
    obj (1,1) ece.Building
    ax (:,1) = [];
end %argblock

%% Create Axis if None Supplied
if isempty(ax)
    f = figure();
    ax = axes("Parent", f, "NextPlot", "add");
end %endif

%% Guard: Check Required Data Exists Before Plotting
% MonthlyOilProfile may not be populated if building has no oil meter.
% BuildingEnergyUsageTable column may be absent if Level2 hasn't run.
hasActual  = ~isempty(obj.MonthlyOilProfile) && ...
    ismember("TotalGallons", obj.MonthlyOilProfile.Properties.VariableNames) && ...
    any(obj.MonthlyOilProfile.TotalGallons ~= 0);

hasModeled = ~isempty(obj.BuildingEnergyUsageTable) && ...
    ismember("HeatingOil_gallons", obj.BuildingEnergyUsageTable.Properties.VariableNames) && ...
    any(obj.BuildingEnergyUsageTable.HeatingOil_gallons(1:12) ~= 0);

if ~hasActual && ~hasModeled
    title(ax, "Actual vs. Modelled Monthly Oil Usage");
    text(0.5, 0.5, "No oil usage data available", ...
        "HorizontalAlignment", "center", ...
        "Units", "normalized", ...
        "Parent", ax);
    return;
end %endif

%% Extract Data Vectors
timeDomain = 1:12;
markerSize = 12;

%% Plot Data
% Only plot whichever series are available.
if hasActual
    actualUsage = obj.MonthlyOilProfile.TotalGallons;
    plot(ax, timeDomain, actualUsage, "k.-", ...
        "MarkerSize", markerSize, ...
        "DisplayName", "Actual (HEA)");
end %endif

if hasModeled
    modeledUsage = obj.BuildingEnergyUsageTable.HeatingOil_gallons(1:12);
    plot(ax, timeDomain, modeledUsage, "b.-", ...
        "MarkerSize", markerSize, ...
        "DisplayName", "Model (Level2)");
end %endif

%% Design Axes
title(ax, "Actual vs. Modelled Monthly Oil Usage");
xlabel(ax, "Month");
ylabel(ax, "Usage (Gallons)");

grid(ax, "on");
axis(ax, "tight");
ylim(ax, [0 inf]);

xticks(ax, timeDomain);
xticklabels(ax, ["January","February","March","April","May", ...
    "June","July","August","September","October","November","December"]);
xtickangle(ax, 45);

legend(ax);

end %function