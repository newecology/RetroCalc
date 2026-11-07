function calculateSolarGains(obj)
%CALCULATESOLARGAINS: Method to compute Solar gains for Glazed Surfaces.
%  Use the location of the Building to compute the total solar Gains. 

%% Arguments Block
arguments
    % obj: Self-referential Building
    obj (1,1) ece.Building
end %argblock

%% Calculate Solar Gains
% Get number of GlazedSurfaces
numGlazedSurfaces = length(obj.GlazedSurfaces);

% Initialize variables for incident solar radiation and solar gains
solarIncident = zeros(12,numGlazedSurfaces);
solarGains = zeros(12,numGlazedSurfaces);

% Create column array of days per month (assume no leap years for now.)
daysPerMonth = [31 28 31 30 31 30 31 31 30 31 30 31]';

%Looping through the glazed surfaces and calculating solar gains for each

for n = 1:height(obj.GlazedSurfaces)
    azimuth = obj.GlazedSurfaces(n).Azimuth_deg;
    tilt = obj.GlazedSurfaces(n).Tilt_deg;

    % get struct with data from PVWatts site via API (has more data than we
    % use)
    [pvData, statusOK] = ece.Solar.getSolarData(azimuth, tilt, ...
        obj.Location.Latitude, obj.Location.Longitude);

    % extract the incident solar radiation data for each orientation, kWh/m2-day
    if statusOK && ~isempty(pvData)
        solarIncident(:,n) = pvData.outputs.solrad_monthly;
    else
        solarIncident(:,n) = zeros(12,1);
    end

    % calculate solar gains for each month for each orientation, kBtu per month
    % .95 is an approximate factor for off normal incidence and dirt
    solarGains(:,n) = solarIncident(:,n) .* 3.412 ./ 10.764 .* ...
        obj.GlazedSurfaces(n).GlazedArea .* .95 ...
        .* obj.GlazedSurfaces(n).SHGC .* daysPerMonth .* ...
        obj.GlazedSurfaces(n).ShadingMonthly;
end  % for loop

% Sum across each row so we have total solar gains per month.
totalSolarGains = sum(solarGains, 2);
obj.TotalSolarGains = totalSolarGains;

% Per-surface breakdown with a trailing Total column and an Annual row —
% exposed via Building.SolarGainsTable for ECM-diagnostic QC.
if numGlazedSurfaces > 0
    surfaceNames = arrayfun(@(g) g.Name, obj.GlazedSurfaces, ...
        'UniformOutput', false);
    % Table column names must be valid identifiers and unique.
    colNames = matlab.lang.makeValidName(string(surfaceNames));
    colNames = matlab.lang.makeUniqueStrings(colNames);
    colNames = [colNames(:)', "Total"];
    monthlyMat  = [solarGains, totalSolarGains];
    annualRow   = sum(monthlyMat, 1);
    rowNames    = ["January","February","March","April","May","June",...
        "July","August","September","October","November","December","Annual"];
    obj.SolarGainsTable = array2table([monthlyMat; annualRow], ...
        'VariableNames', cellstr(colNames), ...
        'RowNames', rowNames);
else
    obj.SolarGainsTable = table();
end

end % end function
