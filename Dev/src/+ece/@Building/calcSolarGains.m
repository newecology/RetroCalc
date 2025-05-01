function calcSolarGains(obj)

% Initialize variables for incident solar radiation and solar gains
solarIncident(height(obj.GlazedSurfaces), 12) = zeros;
solarGains(height(obj.GlazedSurfaces), 12) = zeros;

% Create array of days per month (assume no leap years for now.)
daysPerMonth = [31 28 31 30 31 30 31 31 30 31 30 31];
LocationLatLong = obj.LocationLatLong;

%Looping through the glazed surfaces and calculating solar gains for each

for n = 1:height(obj.GlazedSurfaces)
   azimuth = obj.GlazedSurfaces(n).Azimuth_deg;
   tilt = obj.GlazedSurfaces(n).Tilt_deg;
   
       % get struct with data from PVWatts site via API (has more data than we
% use)
   PVWattsData(n) = ece.Solar.getSolarData(azimuth, tilt, ...
       LocationLatLong(1), LocationLatLong(2));

% extract the incident solar radiation data for each orientation, kWh/m2-day
   solarIncident(n,:) = PVWattsData(n).outputs.solrad_monthly';

% calculate solar gains for each month for each orientation, kBtu per month
% .95 is an approximate factor for off normal incidence and dirt
solarGains(n,:) = solarIncident(n,:) * 3.413 / 10.764 * ...
    obj.GlazedSurfaces(n).GlazedArea * .95 ...
    * obj.GlazedSurfaces(n).SHGC .* daysPerMonth .* ...
    obj.GlazedSurfaces(n).ShadingMonthly;
end  % for loop

   % we may pass through a table of solar gains for each orientation so 
   % the user can see how much gains are due to each set of windows
   totalSolarGains = sum(solarGains, 1);

% push solar gains into building? add property to building class?
obj.totalSolarGains = totalSolarGains;

end % end function 
