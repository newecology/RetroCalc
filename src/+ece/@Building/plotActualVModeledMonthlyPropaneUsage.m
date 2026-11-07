function plotActualVModeledMonthlyPropaneUsage(obj, ax)
% plotActualVModeledMonthlyPropaneUsage: Method to plot the actual
% vs. Modeled monthly usage of Propane for a single year.
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
hasActual  = ~isempty(obj.MonthlyPropaneProfile) && ...
    ismember("Total", obj.MonthlyPropaneProfile.Properties.VariableNames) && ...
    any(obj.MonthlyPropaneProfile.Total ~= 0);

hasModeled = ~isempty(obj.BuildingEnergyUsageTable) && ...
    ismember("Propane_gallons", obj.BuildingEnergyUsageTable.Properties.VariableNames) && ...
    any(obj.BuildingEnergyUsageTable.Propane_gallons(1:12) ~= 0);

if ~hasActual && ~hasModeled
    title(ax, "Actual vs. Modelled Monthly Propane Usage");
    text(0.5, 0.5, "No propane usage data available", ...
        "HorizontalAlignment", "center", ...
        "Units", "normalized", ...
        "Parent", ax);
    return;
end %endif

%% Plot Data
timeDomain = 1:12;
markerSize = 12;

if hasActual
    actualUsage = obj.MonthlyPropaneProfile.Total;
    plot(ax, timeDomain, actualUsage, "k.-", ...
        "MarkerSize", markerSize, ...
        "DisplayName", "Actual (HEA)");
end %endif

if hasModeled
    modeledUsage = obj.BuildingEnergyUsageTable.Propane_gallons(1:12);
    plot(ax, timeDomain, modeledUsage, "b.-", ...
        "MarkerSize", markerSize, ...
        "DisplayName", "Model (Level2)");
end %endif

%% Design Axes
title(ax, "Actual vs. Modelled Monthly Propane Usage");
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