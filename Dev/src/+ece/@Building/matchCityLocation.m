function matchCityLocation(obj)
    %MATCHCITYLOCATION Match a city/state or fallback to manual lat/lon input
    %   Inputs: city (string), state (string)
    %   Outputs:
    %     location - [lat, lon] array
    %     weatherStation - row from weather station table or empty

    % Load reference weather data
    city=obj.LocationCity;
    state=obj.LocationState;
    location=obj.LocationLatLong;
    data = ece.Reference.WeatherCityData;

    %Try to match by City and State
    idx = strcmpi(data.City, city) & strcmpi(data.State, state);
    if any(idx)
        match = data(find(idx, 1), :);
        location = [match.Latitude, match.Longitude];
    else
        error("City and state do not match with an existing location. Please input latitude and longitude of desired location.")
    end
    obj.LocationLatLong=location;

    % %Try to match by coordinates
    % %distances = sqrt((data.Latitude - lat).^2 + (data.Longitude - lon).^2);
    % %[minDist, idx] = min(distances);
    % 
    % %maxAllowedDist = 2; % ~200 km tolerance
    % %if minDist < maxAllowedDist
    %     %match = data(idx, :);
    %     weatherStation = match;
    % 
    %     fprintf("Matched by coordinates to: %s (%s, %s)\n", ...
    %         match.SiteName, match.City, match.State);
    % else
    %     weatherStation = table();  % No match
    %     fprintf("No nearby station found. Latitude/longitude stored only.\n");
    % end
end

