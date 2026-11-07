function plotTotalBaseloadUsage(obj, ax, showAccumulation)
% plotTotalBaseloadUsage: Method to plot the monthly Baseload usage for a
% Building. When DHW is present and lumped with baseload, plots the
% BasePlusDHW vector instead.
arguments
    obj (1,1) ece.Building
    ax (:,1) = [];
    showAccumulation (1,1) logical = false;
end %argblock

%% Create Axis if None Supplied
if isempty(ax)
    f = figure();
    ax = axes("Parent", f, "NextPlot", "add");
end %endif

%% Extract Data Vectors
% Pull both possible baseload vectors from the Monthly Electric Profile.
% BasePlusDHW_kWh is nonzero when DHW is lumped with baseload (i.e.
% IsSpaceHeat+IsDHW or IsCooling+IsDHW cases). Base_kWh is nonzero
% when baseload is isolated (no DHW on this meter).
baseUsage       = obj.MonthlyElectricProfile.Base_kWh;
basePlusDHWUsage = obj.MonthlyElectricProfile.BasePlusDHW_kWh;

% Determine which vector(s) to plot. Guard against both being nonzero
% (should not occur given case logic but handle defensively).
hasBase       = any(baseUsage > 0);
hasBasePlusDHW = any(basePlusDHWUsage > 0);

%% Plot Data
timeDomain = 1:12;
markerSize = 16;

if hasBase
    plotUsage = plot(ax, timeDomain, baseUsage, ...
        "LineStyle", "-", ...
        "Marker", ".", ...
        "MarkerSize", markerSize, ...
        "DisplayName", "Monthly Baseload Usage");

    if showAccumulation
        plot(ax, timeDomain, cumsum(baseUsage), ...
            "LineStyle", "--", ...
            "Marker", ".", ...
            "MarkerSize", markerSize, ...
            "DisplayName", "Accumulated Monthly Baseload Usage");
    end %endif
end %endif

if hasBasePlusDHW
    plotBasePlusDHW = plot(ax, timeDomain, basePlusDHWUsage, ...
        "LineStyle", "-", ...
        "Marker", ".", ...
        "MarkerSize", markerSize, ...
        "DisplayName", "Monthly Baseload + DHW Usage");

    if showAccumulation
        plot(ax, timeDomain, cumsum(basePlusDHWUsage), ...
            "LineStyle", "--", ...
            "Marker", ".", ...
            "MarkerSize", markerSize, ...
            "DisplayName", "Accumulated Monthly Baseload + DHW Usage");
    end %endif
end %endif

%% Design Axes
% Set title dynamically based on which vector was plotted.
if hasBasePlusDHW && ~hasBase
    titleStr = "Building Total Monthly Baseload + DHW Usage";
elseif hasBase && hasBasePlusDHW
    titleStr = "Building Total Monthly Baseload and Baseload + DHW Usage";
else
    titleStr = "Building Total Monthly Baseload Usage";
end %endif

title(ax, titleStr);
xlabel(ax, "Month");
ylabel(ax, "Usage (kWh)");

grid(ax, "on");
axis(ax, "tight");
ylim(ax, [0 inf]);

xticks(ax, timeDomain);
xticklabels(ax, ["January","February","March","April","May", ...
    "June","July","August","September","October","November","December"]);
xtickangle(ax, 45);

legend(ax);

end %function