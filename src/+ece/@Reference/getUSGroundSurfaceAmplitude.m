function amplitude = getUSGroundSurfaceAmplitude(lat, lon)
% Ground Surface Temperature Amplitude lookup for US regions (Fahrenheit)
% Returns annual temperature amplitude based on USGS ground surface data
%
% Inputs:
%   lat - latitude (decimal degrees)
%   lon - longitude (decimal degrees, negative for US)
%
% Output:
%   amplitude - annual ground surface temperature amplitude in Fahrenheit

% Validate US coordinates
if lat < 24 || lat > 70 || lon > -65 || lon < -180
    error('Coordinates outside US bounds');
end

% Define region boundaries and amplitudes [lat_min, lat_max, lon_min, lon_max, amplitude_F]
% Values directly from USGS Ground Surface Temperature Amplitudes map (already in °F)
regions = [
    42, 49, -125, -117, 18;   % Pacific Northwest (15-20°F amplitude)
    42, 49, -104, -90,  28;   % Northern Plains (25-30°F amplitude)
    40, 48, -95,  -75,  23;   % Great Lakes (20-25°F amplitude)
    37, 45, -80,  -65,  23;   % Northeast (20-25°F amplitude)
    32, 40, -125, -117, 18;   % California Central (15-20°F amplitude)
    31, 37, -117, -102, 30;   % Southwest Desert (27-32.5°F amplitude)
    28, 37, -102, -90,  25;   % Southern Plains (22-27°F amplitude)
    28, 37, -90,  -75,  18;   % Southeast (15-20°F amplitude)
    24, 31, -87,  -80,  13;   % Florida (10-15°F amplitude)
    55, 70, -180, -130, 33;   % Alaska (30-35°F amplitude)
    37, 49, -117, -104, 25    % Rocky Mountains (22-27°F amplitude)
    ];

region_names = {'Pacific_Northwest', 'Northern_Plains', 'Great_Lakes', ...
    'Northeast', 'California_Central', 'Southwest_Desert', ...
    'Southern_Plains', 'Southeast', 'Florida', 'Alaska', ...
    'Rocky_Mountains'};

% Find matching region
for i = 1:size(regions, 1)
    if lat >= regions(i,1) && lat <= regions(i,2) && ...
            lon >= regions(i,3) && lon <= regions(i,4)
        amplitude = regions(i,5);
        %fprintf('Region: %s, Ground Surface Amplitude: %.0f°F\n', ...
        %region_names{i}, amplitude);
        return;
    end
end

% If no exact match, find closest region by distance to center
minDistance = inf;
closestRegion = 1;

for i = 1:size(regions, 1)
    centerLat = (regions(i,1) + regions(i,2)) / 2;
    centerLon = (regions(i,3) + regions(i,4)) / 2;
    distance = sqrt((lat - centerLat)^2 + (lon - centerLon)^2);

    if distance < minDistance
        minDistance = distance;
        closestRegion = i;
    end
end

amplitude = regions(closestRegion, 5);

end %classdef