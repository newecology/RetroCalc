function plotActualVModeledMonthlyGasUsage(obj, ax)
% plotActualVModeledMonthlyGasUsage: Method to plot the actual
% vs. Modeled monthly usage of Gas for a single year.
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
hasActual  = ~isempty(obj.MonthlyGasProfile) && ...
    ismember("Total", obj.MonthlyGasProfile.Properties.VariableNames) && ...
    any(obj.MonthlyGasProfile.Total ~= 0);

hasModeled = ~isempty(obj.BuildingEnergyUsageTable) && ...
    ismember("Gas_therms", obj.BuildingEnergyUsageTable.Properties.VariableNames) && ...
    any(obj.BuildingEnergyUsageTable.Gas_therms(1:12) ~= 0);

if ~hasActual && ~hasModeled
    title(ax, "Actual vs. Modelled Monthly Gas Usage");
    text(0.5, 0.5, "No gas usage data available", ...
        "HorizontalAlignment", "center", ...
        "Units", "normalized", ...
        "Parent", ax);
    return;
end %endif

%% Plot Data
timeDomain = 1:12;
markerSize = 12;

if hasActual
    actualUsage = obj.MonthlyGasProfile.Total;
    plot(ax, timeDomain, actualUsage, "k.-", ...
        "MarkerSize", markerSize, ...
        "DisplayName", "Actual (HEA)");
end %endif

if hasModeled
    modeledUsage = obj.BuildingEnergyUsageTable.Gas_therms(1:12);
    plot(ax, timeDomain, modeledUsage, "b.-", ...
        "MarkerSize", markerSize, ...
        "DisplayName", "Model (Level2)");
end %endif

%% Design Axes
title(ax, "Actual vs. Modelled Monthly Gas Usage");
xlabel(ax, "Month");
ylabel(ax, "Usage (Therms)");

grid(ax, "on");
axis(ax, "tight");
ylim(ax, [0 inf]);

xticks(ax, timeDomain);
xticklabels(ax, ["January","February","March","April","May", ...
    "June","July","August","September","October","November","December"]);
xtickangle(ax, 45);

legend(ax);

end %function