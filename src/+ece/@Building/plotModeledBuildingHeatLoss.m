function plotModeledBuildingHeatLoss(obj, ax)
% plotModeledBuildingHeatLoss: Method to plot the
% accumulated contributions of Components to HeatLoss of the Building.
%   This method pulls the components from the Building that have a
%   contribution to the monthly HeatLoss.
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

%% Extract Data Vectors for Each Modeled Component
% The components that contribute to the HeatLoss are as follows:
%  1) Wall
%  2) Roof
%  3) Door
%  4) Window
%  5) Skylight
%  6) Slabs
%  7) Ventilation-Infiltration
%  8) BelowGradeSurfaces

% These values are pulled from various places in the Building.
wallHL = obj.HeatLossComponentsTable.Wall;
roofHL = obj.HeatLossComponentsTable.Roof;
doorHL = obj.HeatLossComponentsTable.Door;
windowHL = obj.HeatLossComponentsTable.Window;
skylightHL = obj.HeatLossComponentsTable.Skylight;
slabsHL = obj.HeatLossComponentsTable.Slabs;
ventInfHL = obj.HeatLossComponentsTable.("Ventilation-Infiltration");
bgsHL = obj.HeatLossComponentsTable.BelowGradeSurfaces;

% Combine into single heatloss matrix.
heatLossMatrix = [...
    wallHL,...
    roofHL,...
    doorHL,...
    windowHL,...
    skylightHL,...
    slabsHL,...
    ventInfHL,...
    bgsHL];

%% Plot Data
% Plot vectors to axes across a 12-month domain from January to
% December.
%   Note: It is assumed both vectors are already
%   chronologically ordered.
% Set up Plot Parameters
timeDomain = 1:12;

% Plot HeatLoss as StackedBar
plotHeatLoss = bar(ax,timeDomain,...
    heatLossMatrix,"stacked");

%% Design Axes
% Update the Axes layout and formatting to explain the plotted
% data.
% -- Axes Labels
title(ax,"Modeled Component Contributions to Building Heat Loss");
xlabel(ax,"Month");
ylabel(ax,"Heat Loss");

% -- Axis Style
grid(ax,"on");
axis(ax,"tight");

% -- TickMark Styling
% Show a tickmark at every data point (for every month).
xticks(ax,timeDomain);

% Map the actual month names to the tickmarks in X axis.
tickLabels = ["January","February","March","April","May",...
    "June","July","August","September","October","November",...
    "December"];
xticklabels(ax,tickLabels);

% Angle Tickmarks
xtickangle(ax,45);

% -- Legend
% Add legend to delineate which bar in the stack is which component.
legend(ax,...
    ["Wall","Roof","Door","Window","Skylight",...
    "Slabsl","Vent/Infil","Below Grade Surfaces"]);

end %function