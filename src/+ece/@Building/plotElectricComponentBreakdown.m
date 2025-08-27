function plotElectricComponentBreakdown(obj, ax)
% plotElectricComponentBreakdown: Method to plot the distribution by component
% of the annual Electric usage.
%   This method pulls the Electric usage for the building into sections as
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

%% Extract Data Vectors for Building HEA Electric Usage
% Pull from the corresponding Utility Monthly Profile
baseUsage = sum(obj.MonthlyElectricProfile.Base);
heatUsage = sum(obj.MonthlyElectricProfile.Heat);
coolUsage = sum(obj.MonthlyElectricProfile.Cool);
totalUsage = sum(obj.MonthlyElectricProfile.Total);

% Compute Percentages
basePercent = (baseUsage / totalUsage) * 100;
heatPercent = (heatUsage / totalUsage) * 100;
coolPercent = (coolUsage / totalUsage) * 100;

%% Plot Data as Pie Chart
% Plot vectors to pie chart.
%   Note: It is assumed both vectors are already
%   chronologically ordered.

% Create Inputs and Labels
pieInput = [basePercent,heatPercent,coolPercent];
pieLabels = ["Baseload","Heating","Cooling"] + " (" + ...
    compose("%0.2f%%",pieInput) + ")";

% Plot HEA Usages as Pie Chart
plotUsage = pie(ax,...
    pieInput,...
    pieLabels);   

%% Design Axes
% Update the Axes layout and formatting to explain the plotted
% data.
% -- Axes Labels
title(ax,"Building Electric Component Usage Breakdown");

% -- Axis Style
grid(ax,"off");
axis(ax,"equal");
axis(ax,"off");

% -- Legend
% Add legend to delineate which bar in the stack is which component.
legend(ax);

end %function