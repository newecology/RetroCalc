function plotActualVModeledMonthlyOilUsage(obj, ax)
% plotActualVModeledMonthlyOilUsage: Method to plot the actual
% vs. Modeled monthly usage of Oil for a single year.
%   This method pulls the Actual (HEA) and Modeled (L2) oil
%   usage values from the Building's BuildingEnergyUsageTable.
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

%% Extract Data Vectors for Actual and Modeled
% Acquire total actual Oil usage data from HEA (kWh)
actualUsage = obj.MonthlyOilProfile.Total;

% Acquire total modeled Oil usage data from Level 2 (gallons)
%   This table column has all 12 months + annual roll-up, so we
%   will only extract the first 12 values.
modeledUsage = obj.BuildingEnergyUsageTable.HeatingOil_gallons(1:12);

%% Plot Data
% Plot vectors to axes across a 12-month domain from January to
% December.
%   Note: It is assumed both vectors are already
%   chronologically ordered.
% Set up Plot Parameters
timeDomain = 1:12;
markerSize = 12;

% Plot HEA Data
plotHEA = plot(ax,timeDomain,actualUsage,'k.-',...
    "MarkerSize",markerSize,...
    "DisplayName","Actual (HEA)");

% Plot L2 Data
plotL2 = plot(ax,timeDomain,modeledUsage,'b.-',...
    "MarkerSize",markerSize,...
    "DisplayName","Model (Level2)");

%% Design Axes
% Update the Axes layout and formatting to explain the plotted
% data.
% -- Axes Labels
title(ax,"Actual vs. Modelled Monthly Oil Usage");
xlabel(ax,"Month");
ylabel(ax,"Usage (Gallons)");

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
% Add legend to delineate which plot is Actual (HEA) vs Modeled
% (L2).
legend(ax);

end %function