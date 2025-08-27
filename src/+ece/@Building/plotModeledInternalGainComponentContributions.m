function plotModeledInternalGainComponentContributions(obj, ax)
% plotModeledInternalGainComponentContributions: Method to plot the
% accumlated contributions of Internal Gains Components to the total.
%   This method pulls the components from the Building that have a
%   contribution to the Monthly Internal Gains kBtu usage, and plots it as
%   a stacked bar over the 12 months of the year.
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
% The components that contribute to the Internal Gains are all columns of
% components in the InternalGainsTable.

% These values are pulled from various places in the Building.
lightUsage = obj.InternalGainsTable.Lights(1:12);
plugLoadUsage = obj.InternalGainsTable.("Plug Loads")(1:12);
peopleSenseUsage = obj.InternalGainsTable.("People Sensible")(1:12);
airmoversUsage = obj.InternalGainsTable.Fans(1:12);
pumpsUsage = obj.InternalGainsTable.Pumps(1:12);
applianceSenseUsage = obj.InternalGainsTable.("Appliances Sensible")(1:12);
dhwUsage = obj.InternalGainsTable.DHW(1:12);
hvacControlUsage = obj.InternalGainsTable.("HVAC Controls")(1:12);
otherSenseUsage = obj.InternalGainsTable.("Other Sensible")(1:12);
peopleLatentUsage = obj.InternalGainsTable.("People Latent")(1:12);
applianceLatentUsage = obj.InternalGainsTable.("Appliances Latent")(1:12);
otherLatentUsage = obj.InternalGainsTable.("Other Latent")(1:12);

% Combine into single usage matrix.
usageMatrix = [...
    lightUsage,...
    plugLoadUsage,...
    peopleSenseUsage,...
    airmoversUsage,...
    pumpsUsage,...
    applianceSenseUsage,...
    dhwUsage,...
    hvacControlUsage,...
    otherSenseUsage,...
    peopleLatentUsage,...
    applianceLatentUsage,...
    otherLatentUsage];

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
title(ax,"Modeled Component Contributions to Internal Gains");
xlabel(ax,"Month");
ylabel(ax,"Internal Gains (kBtu)");

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
    ["Lights","Plug Loads","People Sensible","Air Movers","Pumps",...
    "Appliances Sensible","DHW","HVAC Controls","Other Sensible",...
    "People Latent","Appliances Latent","Other Latent"]);

end %function