function plotModeledElectricComponentContributions(obj, ax)
% plotModeledElectricComponentContributions: Method to plot the
% accumlated contributions of all Electric Components to the Usage.
%   This method pulls the components from the Building that have a
%   contribution to the MonthlyKwH usage, and plots it as a stacked bar
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
% The components that contribute to the Electric Usage are as follows:
%  1) Airmovers
%  2) Pump
%  3) HeatCool Systems
%  4) Appliances
%  5) Lights and Plug Loads (Internal Gains)

% These values are rolled up inside the Building's Electric Usage Table,
% which is populated as it moves through the Level 2 Calulculation.
lightUsage = obj.ElectricUsageTable.Lights(1:12) + ...
    obj.ElectricUsageTable.("ExteriorLights")(1:12);
plugLoadUsage = obj.ElectricUsageTable.("PlugLoads")(1:12);
airmoverUsage = obj.ElectricUsageTable.Fans(1:12);
pumpUsage = obj.ElectricUsageTable.Pumps(1:12);
applianceUsage = obj.ElectricUsageTable.Appliances(1:12);
dhwUsage = obj.ElectricUsageTable.DHW(1:12);
heatUsage = obj.ElectricUsageTable.("SpaceHeating")(1:12);
coolUsage = obj.ElectricUsageTable.("SpaceCooling")(1:12);
otherUsage = obj.ElectricUsageTable.("OtherElec")(1:12);

% Combine into a usage matrix, with each column as a usage.
usageMatrix = [...
    lightUsage,...
    plugLoadUsage,...
    airmoverUsage,...
    pumpUsage,...
    applianceUsage,...
    dhwUsage,...
    heatUsage,...
    coolUsage,...
    otherUsage];

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
title(ax,"Modeled Electric Component Contributions to Electric Usage");
xlabel(ax,"Month");
ylabel(ax,"Usage (kWh)");

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
    ["Lights","Plug Loads","Air Movers","Pumps","Appliances",...
    "DHW","Heat Systems","Cool Systems","Other"]);

end %function