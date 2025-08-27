function plotTotalElectricUsage(obj, ax, showAccumulation)
% plotTotalElectricUsage: Method to plot the monthly Electric usage for a 
% Building.
%   This method pulls the Electric usage for the building as derived from the
%   HEA calculation and plots it over the 12 months of the year.
%   Note: This method takes an input axes; if none exists a
%   default one is spawned.

arguments
    % obj: Self-reference to Building object.
    obj (1,1) ece.Building

    % ax: Handle to Axis to plot into.
    ax (:,1) = [];

    % showAccumulation: Flag to show the accumulation plot as well.
    showAccumulation (1,1) logical = false;

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
totalUsage = obj.MonthlyElectricProfile.Total;

%% Plot Data
% Plot vectors to axes across a 12-month domain from January to
% December.
%   Note: It is assumed both vectors are already
%   chronologically ordered.

% Set up Plot Parameters
timeDomain = 1:12;
markerSize = 16;

% Plot HEA Usages as Line Plot
plotUsage = plot(ax,timeDomain,...
    totalUsage,...
    "LineStyle","-",...
    "Marker",".",...
    "MarkerSize",markerSize,...
    "DisplayName","Monthly Electric Usage");

% Plot HEA Accumulated Usages as Line
if showAccumulation
    plotAccumulatedUsage = plot(ax,timeDomain,...
        cumsum(totalUsage),...
        "LineStyle","-",...
        "Marker",".",...
        "MarkerSize",markerSize,...
        "DisplayName","Accumulated Monthly Electric Usage");
end %endif

%% Design Axes
% Update the Axes layout and formatting to explain the plotted
% data.
% -- Axes Labels
title(ax,"Building Total Monthly Electric Usage");
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
legend(ax);

end %function