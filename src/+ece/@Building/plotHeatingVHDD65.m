function plotHeatingVHDD65(obj, hddData, ax)
% plotHeatingVHDD65Usage: Method to plot the relationship between the
% Building Heating and HDD65.
%   This method pulls the HDD65 and Heating usage for the building as 
%   derived from the HEA calculation and plots the scatter plot
%   relationship between the two.
%   Note: This method takes an input axes; if none exists a
%   default one is spawned

arguments
    % obj: Self-reference to Building object.
    obj (1,1) ece.Building

    % hddData: Vector of HDD65 values.
    hddData (:,1) double

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

%% Extract Data Vectors for Building HEA Heating Usage
% Pull from the corresponding property of Building.
% TODO: Where is this supposed to come from?
totalUsage = rand(size(hddData));

%% Plot Scatter Data
% Plot Heating Usage vs HDD65
%   Note: It is assumed both vectors are sorted and the same length.

% Set up Plot Parameters
markerSize = 16;

% Plot HEA Heat Usages
plotUsage = plot(ax,...
    hddData,...
    totalUsage,...
    "LineStyle","none",...
    "Marker",".",...
    "MarkerSize",markerSize,...
    "DisplayName","HDD65 vs Heating Usage");

%% Compute and Plot Statistics
% Generate the equation for the line of best fit.
coeffs = polyfit(hddData,totalUsage,1);

% Compute the R^2 values from fitted data.
fittedUsage = polyval(coeffs,hddData);
ssTotal = sum((totalUsage - mean(totalUsage)).^2);
ssResidual = sum((totalUsage - fittedUsage).^2);

% Extract Slope and R^2
slope = coeffs(1);
rSquared = 1 - (ssResidual / ssTotal);

% Plot Best-Fit Line
displayName = sprintf("Linear Regression (slope = %0.2f, r^2 = %0.2f)",...
    slope,rSquared);

plotFittedUsage = plot(ax,...
    hddData,...
    fittedUsage,...
    "LineStyle","-",...
    "DisplayName",displayName);

%% Design Axes
% Update the Axes layout and formatting to explain the plotted
% data.
% -- Axes Labels
title(ax,"Total Building HDD65 vs Heating Usage");
xlabel(ax,"HDD65 (F-days)");
ylabel(ax,"Heating Usage (therms)");

% -- Axis Style
grid(ax,"on");
axis(ax,"tight");

% -- Reset Tick
ax.XTickMode = "auto";
ax.XTickLabelMode = "auto";

% -- Legend
% Add legend to delineate which bar in the stack is which component.
legend(ax);

end %function