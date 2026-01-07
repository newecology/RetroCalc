function plotOilComponentBreakdown(obj, ax)
% plotOilComponentBreakdown: Method to plot the distribution by component
% of the annual Oil usage.
%   This method pulls the Oil usage for the building into sections as
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

%% Extract Data Vectors for Building HEA Oil Usage
% Pull from the corresponding Utility Monthly Profile
dhwUsage = sum(obj.MonthlyOilProfile.DHWGallons);
spaceHeatUsage = sum(obj.MonthlyOilProfile.SpaceHeatGallons);
totalUsage = sum(obj.MonthlyOilProfile.TotalGallons);

% Compute Percentages
dhwPercent = (dhwUsage / totalUsage) * 100;
spaceHeatPercent = (spaceHeatUsage / totalUsage) * 100;

%% Plot Data as Pie Chart
% Plot vectors to pie chart.
%   Note: It is assumed both vectors are already
%   chronologically ordered.

% Create Inputs and Labels
pieInput = [dhwPercent,spaceHeatPercent];
pieLabels = ["DHW","Space Heat"] + ...
    " (" + compose("%0.2f%%",pieInput) + ")";

% Plot HEA Usages as Pie Chart
plotUsage = pie(ax,...
    pieInput,...
    pieLabels);   

%% Design Axes
% Update the Axes layout and formatting to explain the plotted
% data.
% -- Axes Labels
title(ax,"Building Oil Component Usage Breakdown");

% -- Axis Style
grid(ax,"off");
axis(ax,"equal");
axis(ax,"off");

% -- Legend
% Add legend to delineate which bar in the stack is which component.
legend(ax);

end %function