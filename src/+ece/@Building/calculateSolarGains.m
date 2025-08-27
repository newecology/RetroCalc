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
    PVWattsData(n) = ece.Solar.getSolarData(azimuth, tilt, ...
        obj.Location.Latitude, obj.Location.Longitude);

    % extract the incident solar radiation data for each orientation, kWh/m2-day
    solarIncident(:,n) = PVWattsData(n).outputs.solrad_monthly;

    % calculate solar gains for each month for each orientation, kBtu per month
    % .95 is an approximate factor for off normal incidence and dirt
    solarGains(:,n) = solarIncident(:,n) .* 3.413 ./ 10.764 .* ...
        obj.GlazedSurfaces(n).GlazedArea .* .95 ...
        .* obj.GlazedSurfaces(n).SHGC .* daysPerMonth .* ...
        obj.GlazedSurfaces(n).ShadingMonthly;
end  % for loop

% we may pass through a table of solar gains for each orientation so
% the user can see how much gains are due to each set of windows.
% Sum across each row so we have total solar gains per month.
totalSolarGains = sum(solarGains, 2);

% push solar gains into building? add property to building class?
obj.TotalSolarGains = totalSolarGains;

end % end function
