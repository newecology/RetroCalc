function plotModeledGasComponentContributions(obj, ax)
% plotModeledGasComponentContributions: Method to plot the
% accumlated contributions of all Gas Components to the Usage.
%   This method pulls the components from the Building that have a
%   contribution to the Monthly Therms usage, and plots it as a stacked bar
%   over the 12 months of the year.
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
% The components that contribute to the Gas Usage are as follows:
%  1) Heating Systems
%  2) DHW Usage
%  3) Cooking and Drying Appliances

% These values are pulled from various places in the Building.
heatUsage = obj.HeatFuelTable.Gas_therms(1:12);
dhwUsage = obj.DHWfuelTable{2,2:13}';
applianceUsage = obj.ApplianceEnergyTable12{2,1:12}';

% Combine into single usage matrix.
usageMatrix = [...
    heatUsage,...
    dhwUsage,...
    applianceUsage];

%% Plot Data
% Plot vectors to axes across a 12-month domain from January to
% December.
%   Note: It is assumed both vectors are already
%   chronologically ordered.
% Set up Plot Parameters
timeDomain = 1:12;

% Plot L2 Usages as Stacked Plot
plotL2 = bar(ax,timeDomain,...
    usageMatrix,"stacked");

%% Design Axes
% Update the Axes layout and formatting to explain the plotted
% data.
% -- Axes Labels
title(ax,"Modeled Gas Component Contributions to Gas Usage");
xlabel(ax,"Month");
ylabel(ax,"Usage (therms)");

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
    ["Heat Systems","DHW Systems","Appliances"]);

end %function