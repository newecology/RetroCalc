function plotCoolingVCDD70(obj, cddData, ax)
% plotCoolingVCDD70Usage: Method to plot the relationship between the
% Building Cooling and CDD70.
%   This method pulls the CDD70 and Cooling usage for the building as 
%   derived from the HEA calculation and plots the scatter plot
%   relationship between the two.
%   Note: This method takes an input axes; if none exists a
%   default one is spawned

arguments
    % obj: Self-reference to Building object.
    obj (1,1) ece.Building

    % cddData: Vector of CDD70 values.
    cddData (:,1) double

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

%% Extract Data Vectors for Building HEA Cooling Usage
% Pull from the corresponding property of Building.
% TODO: Where is this supposed to come from?
totalUsage = rand(size(cddData));

%% Plot Scatter Data
% Plot Cooling Usage vs CDD70
%   Note: It is assumed both vectors are sorted and the same length.

% Set up Plot Parameters
markerSize = 16;

% Plot HEA Heat Usages
plotUsage = plot(ax,...
    cddData,...
    totalUsage,...
    "LineStyle","none",...
    "Marker",".",...
    "MarkerSize",markerSize,...
    "DisplayName","CDD70 vs Cooling Usage");

%% Compute and Plot Statistics
% Generate the equation for the line of best fit.
coeffs = polyfit(cddData,totalUsage,1);

% Compute the R^2 values from fitted data.
fittedUsage = polyval(coeffs,cddData);
ssTotal = sum((totalUsage - mean(totalUsage)).^2);
ssResidual = sum((totalUsage - fittedUsage).^2);

% Extract Slope and R^2
slope = coeffs(1);
rSquared = 1 - (ssResidual / ssTotal);

% Plot Best-Fit Line
displayName = sprintf("Linear Regression (slope = %0.2f, r^2 = %0.2f)",...
    slope,rSquared);

plotFittedUsage = plot(ax,...
    cddData,...
    fittedUsage,...
    "LineStyle","-",...
    "DisplayName",displayName);

%% Design Axes
% Update the Axes layout and formatting to explain the plotted
% data.
% -- Axes Labels
title(ax,"Total Building CDD70 vs Cooling Usage");
xlabel(ax,"CDD70 (F-days)");
ylabel(ax,"Cooling Usage (therms)");

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