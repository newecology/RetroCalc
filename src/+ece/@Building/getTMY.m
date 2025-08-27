function [temp, rh, wind] = getTMY(api_key, lat, lon)
% GET_NREL_WEATHER_DATA Retrieves weather data from NREL's API
%
% This function makes a request to the NREL NSRDB Data Viewer API
% and returns dry bulb temperature, relative humidity, and wind speed.
%
% Parameters:
%   api_key - Your NREL API key (string)
%   lat - Latitude of the location (numeric)
%   lon - Longitude of the location (numeric)
%
% Returns:
%   temp - Dry bulb temperature (°C) as hourly data for a TMY
%   rh   - Relative humidity (%) as hourly data for a TMY
%   wind - Wind speed (m/s) as hourly data for a TMY
%
% Example:
%   api_key = 'YOUR_API_KEY_HERE';
%   [temp, rh, wind] = get_nrel_weather_data(api_key, 39.7392, -104.9903);
%
% Note: You must obtain an API key from https://developer.nrel.gov/signup/

% Validate inputs
if nargin < 3
    error('Required parameters: api_key, lat, and lon');
end

% Email is required by NREL API - replace with your email
your_email = 'goswami@newecology.com';

% Base URL for the NREL API
% Using the NSRDB Data Viewer API endpoint
base_url = 'https://developer.nrel.gov/api/nsrdb/v2/solar/psm3-tmy-download.csv';

% Build the request URL with parameters
url = [base_url, '?', ...
       'api_key=', api_key, '&', ...
       'email=', your_email, '&', ...
       'latitude=', num2str(lat), '&', ...
       'longitude=', num2str(lon), '&', ...
       'names=2019&', ...
       'interval=60&', ...
       'utc=false&', ...
       'attributes=dhi,dni,ghi,wind_speed,air_temperature,relative_humidity'];

% Display status
disp('Sending request to NREL API...');
disp(['URL: ' url]);

try
    % Make the HTTP request
    options = weboptions('ContentType', 'text', 'Timeout', 120);
    data_raw = webread(url, options);
    
    % Parse the CSV data
    disp('Processing weather data...');
    
    % Split into lines
    lines = strsplit(data_raw, '\n');
    
    % Find the header line with variable names
    header_line = 0;
    for i = 1:length(lines)
        if contains(lower(lines{i}), 'year') && contains(lower(lines{i}), 'month') && contains(lower(lines{i}), 'day')
            header_line = i;
            break;
        end
    end
    
    if header_line == 0
        error('Could not find header line in the response');
    end
    
    % Parse header to find column indices
    headers = strsplit(lines{header_line}, ',');
    
    % Find columns for our desired variables (case-insensitive search)
    temp_col = find(contains(lower(headers), 'temp') | contains(lower(headers), 'air_temperature'), 1);
    rh_col = find(contains(lower(headers), 'humidity') | contains(lower(headers), 'relative_humidity'), 1);
    wind_col = find(contains(lower(headers), 'wind') | contains(lower(headers), 'wind_speed'), 1);
    
    if isempty(temp_col) || isempty(rh_col) || isempty(wind_col)
        error('Could not find all required columns in the data. Available columns: %s', strjoin(headers, ', '));
    end
    
    % Parse the data lines
    data_lines = lines(header_line+1:end);
    
    % Initialize arrays
    hours_in_year = 8760;
    temp = zeros(hours_in_year, 1);
    rh = zeros(hours_in_year, 1);
    wind = zeros(hours_in_year, 1);
    
    % Process each data line
    valid_lines = 0;
    for i = 1:length(data_lines)
        line = data_lines{i};
        if ~isempty(line) && ~all(isspace(line))
            values = strsplit(line, ',');
            
            % Only process if we have enough columns
            if length(values) >= max([temp_col, rh_col, wind_col])
                valid_lines = valid_lines + 1;
                
                % Convert string values to numbers, handle errors
                try
                    temp(valid_lines) = str2double(values{temp_col});
                    rh(valid_lines) = str2double(values{rh_col});
                    wind(valid_lines) = str2double(values{wind_col});
                catch
                    % Skip this line if conversion fails
                    valid_lines = valid_lines - 1;
                end
            end
        end
    end
    
    % Trim arrays if not all lines were valid
    if valid_lines < hours_in_year
        temp = temp(1:valid_lines);
        rh = rh(1:valid_lines);
        wind = wind(1:valid_lines);
    end
    
    disp(['Successfully retrieved ' num2str(valid_lines) ' hours of weather data']);
    
    % Quick statistical summary
    disp(['Temperature: Min = ' num2str(min(temp)) '°C, Max = ' num2str(max(temp)) '°C, Avg = ' num2str(mean(temp)) '°C']);
    disp(['Relative Humidity: Min = ' num2str(min(rh)) '%, Max = ' num2str(max(rh)) '%, Avg = ' num2str(mean(rh)) '%']);
    disp(['Wind Speed: Min = ' num2str(min(wind)) 'm/s, Max = ' num2str(max(wind)) 'm/s, Avg = ' num2str(mean(wind)) 'm/s']);
    
    % Alternative approach - if the data format is complex, try using MATLAB's table functions
    if valid_lines == 0
        disp('Trying alternative parsing method...');
        % Create a temporary file to use csvread
        temp_file = [tempname '.csv'];
        fid = fopen(temp_file, 'w');
        fprintf(fid, '%s', data_raw);
        fclose(fid);
        
        % Read using MATLAB's CSV import
        try
            T = readtable(temp_file);
            delete(temp_file);
            
            % Find the column names that match our desired variables
            temp_col_name = '';
            rh_col_name = '';
            wind_col_name = '';
            
            col_names = T.Properties.VariableNames;
            for i = 1:length(col_names)
                col = lower(col_names{i});
                if contains(col, 'temp') || contains(col, 'air')
                    temp_col_name = col_names{i};
                elseif contains(col, 'humid') || contains(col, 'rh')
                    rh_col_name = col_names{i};
                elseif contains(col, 'wind')
                    wind_col_name = col_names{i};
                end
            end
            
            % Extract data if columns were found
            if ~isempty(temp_col_name) && ~isempty(rh_col_name) && ~isempty(wind_col_name)
                temp = T.(temp_col_name);
                rh = T.(rh_col_name);
                wind = T.(wind_col_name);
                
                disp(['Successfully parsed data with alternative method. Found ' num2str(length(temp)) ' records.']);
            else
                error('Could not identify required columns in the parsed table');
            end
        catch ME
            delete(temp_file);
            disp(['Alternative method failed: ' ME.message]);
            error('Both parsing methods failed');
        end
    end
    
catch ME
    % Display more detailed error information
    disp('Error details:');
    disp(getReport(ME, 'extended'));
    
    % Try to display response if possible
    if exist('data_raw', 'var') && ~isempty(data_raw)
        disp('First 500 characters of API response:');
        disp(data_raw(1:min(500, length(data_raw))));
    end
    
    error('Error retrieving weather data: %s', ME.message);
end

% Example of how to plot the data
figure;

% Plot temperature
subplot(3,1,1);
plot(temp);
title('Dry Bulb Temperature');
ylabel('Temperature (°C)');
grid on;

% Plot humidity
subplot(3,1,2);
plot(rh);
title('Relative Humidity');
ylabel('RH (%)');
grid on;

% Plot wind speed
subplot(3,1,3);
plot(wind);
title('Wind Speed');
xlabel('Hour of Year');
ylabel('Wind Speed (m/s)');
grid on;

end