function plotElectricComponentBreakdown(obj, ax)
% plotElectricComponentBreakdown: Method to plot the distribution by component
% of the annual Electric usage.
arguments
    obj (1,1) ece.Building
    ax (:,1) = [];
end %argblock

%% Create Axis if None Supplied
if isempty(ax)
    f = figure();
    ax = axes("Parent", f, "NextPlot", "add");
end %endif

%% Extract Annual Totals
baseUsage        = sum(obj.MonthlyElectricProfile.Base_kWh);
heatUsage        = sum(obj.MonthlyElectricProfile.Heat_kWh);
coolUsage        = sum(obj.MonthlyElectricProfile.Cool_kWh);
DHWUsage         = sum(obj.MonthlyElectricProfile.DHW_kWh);
basePlusDHWUsage = sum(obj.MonthlyElectricProfile.BasePlusDHW_kWh);
totalUsage       = sum(obj.MonthlyElectricProfile.Total_kWh);

%% Guard Against Zero Total
if totalUsage == 0
    title(ax, "Building Electric Component Usage Breakdown");
    text(0.5, 0.5, "No usage data available", ...
        "HorizontalAlignment", "center", ...
        "Units", "normalized", ...
        "Parent", ax);
    return;
end %endif

%% Compute Percentages
pieValues = [baseUsage, heatUsage, coolUsage, DHWUsage basePlusDHWUsage] ...
    ./ totalUsage * 100;
pieLabels = ["Baseload", "Heating", "Cooling","DHW", "Baseload + DHW"];

%% Filter Zero Slices
% pie() errors on zero-value slices. Remove any component with no usage.
nonZeroMask = pieValues > 0;
pieValues   = pieValues(nonZeroMask);
pieLabels   = pieLabels(nonZeroMask);

%% Append Percentage to Labels
pieLabels = pieLabels + " (" + compose("%0.2f%%", pieValues) + ")";

%% Plot
pie(ax, pieValues, pieLabels);

%% Design Axes
title(ax, "Building Electric Component Usage Breakdown");
grid(ax, "off");
axis(ax, "equal");
axis(ax, "off");
legend(ax);

end %function