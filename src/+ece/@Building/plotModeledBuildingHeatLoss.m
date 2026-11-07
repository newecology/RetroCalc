function plotModeledBuildingHeatLoss(obj, ax)
% plotModeledBuildingHeatLoss: Method to plot the accumulated contributions
% of Components to HeatLoss of the Building.
% Only components with nonzero heat loss contributions are plotted,
% making the function robust to buildings that lack skylights, slabs, etc.
arguments
    obj (1,1) ece.Building
    ax (:,1) = [];
end %argblock

%% Create Axis if None Supplied
if isempty(ax)
    f = figure();
    ax = axes("Parent", f, "NextPlot", "add");
end %endif

%% Define All Possible Components and Labels
% Order here controls stacking order in bar chart.
componentNames = ["Wall", "Roof", "Door", "Window", "Skylight", ...
    "Slabs", "Ventilation-Infiltration", "BelowGradeSurfaces"];
displayLabels = ["Wall", "Roof", "Door", "Window", "Skylight", ...
    "Slabs", "Vent/Infil", "Below Grade Surfaces"];

%% Extract and Filter Components
% Build matrix and label list dynamically — skip any component
% whose annual total is zero (not present in this building).
heatLossMatrix = [];
activeLabels   = string.empty;

for i = 1:numel(componentNames)
    colName = componentNames(i);

    % Guard: check column exists in table before accessing
    if ~ismember(colName, obj.HeatLossComponentsTable.Properties.VariableNames)
        continue;
    end %endif

    colData = obj.HeatLossComponentsTable.(colName);

    % Only include if component has nonzero contribution
    if any(colData ~= 0)
        heatLossMatrix = [heatLossMatrix, colData]; %#ok<AGROW>
        activeLabels(end+1) = displayLabels(i);     %#ok<AGROW>
    end %endif

end %for

%% Guard Against Empty Matrix
if isempty(heatLossMatrix)
    title(ax, "Modeled Component Contributions to Building Heat Loss");
    text(0.5, 0.5, "No heat loss data available", ...
        "HorizontalAlignment", "center", ...
        "Units", "normalized", ...
        "Parent", ax);
    return;
end %endif

%% Plot Data
timeDomain = 1:12;
bar(ax, timeDomain, heatLossMatrix, "stacked");

%% Design Axes
title(ax, "Modeled Component Contributions to Building Heat Loss");
xlabel(ax, "Month");
ylabel(ax, "Heat Loss (BTU/hr·°F)");

grid(ax, "on");
axis(ax, "tight");

xticks(ax, timeDomain);
xticklabels(ax, ["January","February","March","April","May", ...
    "June","July","August","September","October","November","December"]);
xtickangle(ax, 45);

legend(ax, activeLabels);

end %function