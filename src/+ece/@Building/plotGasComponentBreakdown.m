function plotGasComponentBreakdown(obj, ax)
% plotGasComponentBreakdown: Method to plot the distribution by component
% of the annual Gas usage.
%   This method pulls the Gas usage for the building into sections as
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

%% Extract Data Vectors for Building HEA Gas Usage
% Pull from the corresponding Utility Monthly Profile
spaceHeatingUsage = sum(obj.MonthlyGasProfile.SpaceHeatTherms);
stoveDryerUsage = sum(obj.MonthlyGasProfile.StoveDryerTherms);
dhwUsage = sum(obj.MonthlyGasProfile.DHWTherms);
totalUsage = sum(obj.MonthlyGasProfile.Total);

% Compute Percentages
spaceHeatingPercent = (spaceHeatingUsage / totalUsage) * 100;
stoveDryerPercent = (stoveDryerUsage / totalUsage) * 100;
dhwPercent = (dhwUsage / totalUsage) * 100;

%% Plot Data as Pie Chart
% Plot vectors to axes across a 12-month domain from January to
% December.
%   Note: It is assumed both vectors are already
%   chronologically ordered.

% Create Inputs and Labels
pieInput = [spaceHeatingPercent,stoveDryerPercent,dhwPercent];
pieLabels = ["Space Heating","Stove/Dryer","DHW"] + " (" + ...
    compose("%0.2f%%",pieInput) + ")";

% Plot HEA Usages as Pie Chart
plotUsage = pie(ax,...
    pieInput,...
    pieLabels);   

%% Design Axes
% Update the Axes layout and formatting to explain the plotted
% data.
% -- Axes Labels
title(ax,"Building Gas Component Usage Breakdown");

% -- Axis Style
grid(ax,"off");
axis(ax,"equal");
axis(ax,"off");

% -- Legend
% Add legend to delineate which bar in the stack is which component.
legend(ax);

end %function