function plotWaterComponentBreakdown(obj, ax)
% plotWaterComponentBreakdown: Method to plot the distribution by component
% of the annual Water usage.
%   This method pulls the Water usage for the building into sections as
%   defined by the different usages allocated to it, and plots it as a pie
%   chart.
%   Note: This method takes an input axes; if none exists a
%   default one is spawned.

arguments
    % obj: Self-reference to Building object.
    obj (1,1) ece.Building

    % ax: Handle to Axis to plot into.
    ax (:,1) = [];

end %argblock

%% Create Axis if None Supplied
% If this plot isn't specifically rendered anywhere, create a
% default figure and axes to parent to.
if isempty(ax)
    % Create Figure
    f = figure();

    % Create Axes with Specifications
    ax = axes("Parent",f,...
        "NextPlot","add");

end %endif

%% Extract Data Vectors for Building HEA Water Usage
% Pull from the corresponding Utility Monthly Profile
irrigationUsage = sum(obj.MonthlyWaterProfile.IrrigationGals);
coolingTowerUsage = sum(obj.MonthlyWaterProfile.CoolingTowerGals);
otherUsage = sum(obj.MonthlyWaterProfile.OtherUseGals);
residentialUsage = sum(obj.MonthlyWaterProfile.ResidentialGals);
totalUsage = sum(obj.MonthlyWaterProfile.TotalGallons);

% Compute Percentages
irrigationPercent = (irrigationUsage / totalUsage) * 100;
coolingTowerPercent = (coolingTowerUsage / totalUsage) * 100;
otherPercent = (otherUsage / totalUsage) * 100;
residentialPercent = (residentialUsage / totalUsage) * 100;

%% Plot Data as Pie Chart
% Plot vectors to pie chart.
%   Note: It is assumed both vectors are already
%   chronologically ordered.

% Create Inputs and Labels
pieInput = [irrigationPercent,coolingTowerPercent,...
    otherPercent,residentialPercent];
pieLabels = ["Irrigation","Cooling Tower",...
    "Other","Residential"] + ...
    " (" + compose("%0.2f%%",pieInput) + ")";

% Plot HEA Usages as Pie Chart
plotUsage = pie(ax,...
    pieInput,...
    pieLabels);   

%% Design Axes
% Update the Axes layout and formatting to explain the plotted
% data.
% -- Axes Labels
title(ax,"Building Water Component Usage Breakdown");

% -- Axis Style
grid(ax,"off");
axis(ax,"equal");
axis(ax,"off");

% -- Legend
% Add legend to delineate which bar in the stack is which component.
legend(ax);

end %function