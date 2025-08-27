function degreedays_data = fromDegreeDaysNetAPI(latitude, longitude, base_temp_f, options)
% FROMDEGREEDAYSNETAPI
% This function retrieves historical heating or cooling degree days (HDD/CDD)
% data from the DegreeDays.net API for utility data analysis, weather
% normalization, and energy trend modeling.
%
% USAGE:
%   data = fromDegreeDaysnet(42.3601, -71.0589)  % Uses default base temps [65, 70]
%   data = fromDegreeDaysnet(42.3601, -71.0589, [65, 70])
%   data = fromDegreeDaysnet(lat, lon, [], struct('averagingPeriodInYears', 5))
%
% INPUTS:
%   latitude - Latitude coordinate (numeric, required)
%   longitude - Longitude coordinate (numeric, required)
%   base_temp_f - Base temperatures [HDD_base, CDD_base] (default [65, 70])
%   options - Optional struct with fields:
%     - averagingPeriodInYears: Number of years to look back (default 10)
%     - endDate: End date 'YYYY-MM-DD' format (default today)
%     - startDate: Start date 'YYYY-MM-DD' format (auto-calculated if not provided)
%     - account_key: Your API account key (default uses test key)
%     - security_key: Your API security key (default uses test key)
%     - endpoint: API endpoint URL (default HTTP endpoint)
%     - breakdown: 'daily', 'monthly', or 'yearly' (default 'daily')
%
% OUTPUT:
%   degreedays_data - Table with columns:
%     - Date: Date column (datetime)
%     - HDD65: Heating degree days with base 65°F (or custom HDD base)
%     - CDD70: Cooling degree days with base 70°F (or custom CDD base)
%
% EXAMPLE:
%   % Get 5 years of degree days for Boston area
%   options = struct('averagingPeriodInYears', 5);
%   data = fromDegreeDaysnet(42.3601, -71.0589, [], options);
%
% Author: Sankhanil Goswami, 2025


%% Importing java libraries
import java.security.* javax.crypto.* javax.crypto.spec.*
import java.util.Base64

%% Input validation
if nargin < 2
    error('fromDegreeDaysnet:InsufficientInputs', ...
        'Function requires at least latitude and longitude');
end

% Set default base temperatures: HDD 65°F, CDD 70°F
if nargin < 3 || isempty(base_temp_f)
    base_temp_f = [65, 70];  % [HDD_base, CDD_base]
end

% Validate base temperatures
if length(base_temp_f) ~= 2
    error('fromDegreeDaysnet:InvalidBaseTemps', ...
        'base_temp_f must be a 2-element array [HDD_base, CDD_base]');
end

hdd_base = base_temp_f(1);
cdd_base = base_temp_f(2);

% Validate latitude and longitude
if ~isnumeric(latitude) || ~isscalar(latitude) || latitude < -90 || latitude > 90
    error('fromDegreeDaysnet:InvalidLatitude', ...
        'Latitude must be a numeric scalar between -90 and 90');
end

if ~isnumeric(longitude) || ~isscalar(longitude) || longitude < -180 || longitude > 180
    error('fromDegreeDaysnet:InvalidLongitude', ...
        'Longitude must be a numeric scalar between -180 and 180');
end

% Set default options
if nargin < 4 || isempty(options)
    options = struct();
end

% Setting account number and account key from environment
options = ece.Reference.getCredentialsFromEnvironment();
% Default settings aligned with requirements
if ~isfield(options, 'averagingPeriodInYears')
    options.averagingPeriodInYears = 10;  % 10-year default for utility analysis
end
if ~isfield(options, 'endDate')
    options.endDate = char(datetime('today', 'Format', 'yyyy-MM-dd'));
end
if ~isfield(options, 'startDate')
    % Auto-calculate start date: end date - averaging period
    end_dt = datetime(options.endDate, 'InputFormat', 'yyyy-MM-dd');
    start_dt = end_dt - years(options.averagingPeriodInYears);
    options.startDate = char(start_dt, 'yyyy-MM-dd');
end
if ~isfield(options, 'account_key')
    options.account_key = 'test-test-test';
end
if ~isfield(options, 'security_key')
    options.security_key = 'test-test-test-test-test-test-test-test-test-test-test-test-test';
end
if ~isfield(options, 'endpoint')
    options.endpoint = 'http://apiv1.degreedays.net/json';
end
if ~isfield(options, 'breakdown')
    options.breakdown = 'daily';
end

% Log the request details
fprintf('fromDegreeDaysnet: Requesting data for location [%.4f, %.4f]\n', latitude, longitude);
fprintf('fromDegreeDaysnet: Date range: %s to %s (%.1f years)\n', ...
    options.startDate, options.endDate, options.averagingPeriodInYears);

%% BUILD LOCATION OBJECT
try

    % Use lat/lon structure as required
    location = struct('type', 'LongLatLocation', ...
        'longLat', struct('longitude', longitude, ...
        'latitude', latitude));


    switch lower(options.breakdown)
        case 'daily'
            breakdown = struct('type', 'DailyBreakdown', ...
                'period', struct('type', 'DayRangePeriod', ...
                'dayRange', struct('first', options.startDate, ...
                'last', options.endDate)));
        case 'monthly'
            breakdown = struct('type', 'MonthlyBreakdown', ...
                'period', struct('type', 'DayRangePeriod', ...
                'dayRange', struct('first', options.startDate, ...
                'last', options.endDate)));
        case 'yearly'
            breakdown = struct('type', 'YearlyBreakdown', ...
                'period', struct('type', 'DayRangePeriod', ...
                'dayRange', struct('first', options.startDate, ...
                'last', options.endDate)));
        otherwise
            error('fromDegreeDaysnet:InvalidBreakdown', ...
                'breakdown must be ''daily'', ''monthly'', or ''yearly''');
    end

    %% BUILD DATA SPECIFICATIONS
    data_specs = struct();

    % HDD specification
    field_name = sprintf('hdd_%d', round(hdd_base));
    data_specs.(field_name) = struct(...
        'type', 'DatedDataSpec', ...
        'calculation', struct(...
        'type', 'HeatingDegreeDaysCalculation', ...
        'baseTemperature', struct('unit', 'F', 'value', hdd_base)), ...
        'breakdown', breakdown);

    % CDD specification
    field_name = sprintf('cdd_%d', round(cdd_base));
    data_specs.(field_name) = struct(...
        'type', 'DatedDataSpec', ...
        'calculation', struct(...
        'type', 'CoolingDegreeDaysCalculation', ...
        'baseTemperature', struct('unit', 'F', 'value', cdd_base)), ...
        'breakdown', breakdown);

    %% BUILD COMPLETE REQUEST
    % Generate timestamp and random string for security
    timestamp = char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd''T''HH:mm:ss''Z'''));
    random_str = char(java.util.UUID.randomUUID());

    % Build the complete request
    request = struct(...
        'securityInfo', struct(...
        'endpoint', options.endpoint, ...
        'accountKey', options.account_key, ...
        'timestamp', timestamp, ...
        'random', random_str), ...
        'request', struct(...
        'type', 'LocationDataRequest', ...
        'location', location, ...
        'dataSpecs', data_specs));

    %% SEND API REQUEST
    % Convert request to JSON
    request_json = jsonencode(request);

    % Create HMAC-SHA256 signature

    key_bytes = uint8(options.security_key);
    message_bytes = uint8(request_json);
    secret_key = SecretKeySpec(key_bytes, 'HmacSHA256');
    mac = Mac.getInstance('HmacSHA256');
    mac.init(secret_key);
    signature = mac.doFinal(message_bytes);

    % Base64URL encode request and signature

    encoder = Base64.getEncoder();

    % Encode request
    base64_request = char(encoder.encode(uint8(request_json)))';
    encoded_request = strrep(base64_request, '+', '-');
    encoded_request = strrep(encoded_request, '/', '_');
    encoded_request = regexprep(encoded_request, '=+$', '');

    % Encode signature
    base64_signature = char(encoder.encode(signature))';
    encoded_signature = strrep(base64_signature, '+', '-');
    encoded_signature = strrep(encoded_signature, '/', '_');
    encoded_signature = regexprep(encoded_signature, '=+$', '');

    % Prepare HTTP parameters
    params = struct(...
        'request_encoding', 'base64url', ...
        'signature_method', 'HmacSHA256', ...
        'signature_encoding', 'base64url', ...
        'encoded_request', encoded_request, ...
        'encoded_signature', encoded_signature);

    % Send HTTP request with enhanced error handling
    try
        % Try using webread with query parameters
        response_json = webread(options.endpoint, params, ...
            weboptions('RequestMethod', 'POST', 'Timeout', 30));
    catch webread_error
        % Enhanced error handling for different failure modes
        if contains(webread_error.message, 'timeout')
            error('fromDegreeDaysnet:NetworkTimeout', ...
                'Network timeout occurred. Please check your internet connection and try again or upload degree days data externally.');
        else
            % Fallback: Use Java HTTP client directly
            try
                response_json = send_request_via_java(options.endpoint, params);
            catch java_error
                error('fromDegreeDaysnet:NetworkError', ...
                    'Failed to connect to API: %s', java_error.message);
            end
        end
    end

    response = jsondecode(response_json);

    %% ENHANCED ERROR HANDLING
    if strcmp(response.response.type, 'Failure')
        error_code = response.response.code;
        error_message = response.response.message;

        % Log the error with details
        fprintf('fromDegreeDaysnet ERROR: %s - %s\n', error_code, error_message);

        % Handle specific error types per requirements
        if startsWith(error_code, 'RateLimit')
            if isfield(response, 'metadata') && isfield(response.metadata, 'rateLimit')
                minutes_to_reset = response.metadata.rateLimit.minutesToReset;
                error('fromDegreeDaysnet:RateLimitExceeded', ...
                    ['API rate limit exceeded. Please wait %d minutes before retrying.\n' ...
                    'Alternatively, you can upload degree days data manually via Excel.\n' ...
                    'Consider upgrading your API plan for higher limits.'], minutes_to_reset);
            else
                error('fromDegreeDaysnet:RateLimitExceeded', ...
                    ['API rate limit exceeded. Please try again later.\n' ...
                    'Alternatively, you can upload degree days data manually via Excel.\n' ...
                    'Consider upgrading your API plan for higher limits.']);
            end
        elseif startsWith(error_code, 'InvalidRequestAccount')
            error('fromDegreeDaysnet:InvalidCredentials', ...
                'Invalid API credentials. Please check your account_key and security_key.');
        elseif startsWith(error_code, 'InvalidRequestForAccountPlan')
            error('fromDegreeDaysnet:PlanLimitation', ...
                ['Your API plan does not support this request.\n' ...
                'Please upgrade your plan or upload degree days data manually via Excel.']);
        elseif startsWith(error_code, 'Location')
            error('fromDegreeDaysnet:LocationError', ...
                'Location not recognized or supported: [%.4f, %.4f]\n%s', ...
                latitude, longitude, error_message);
        else
            error('fromDegreeDaysnet:APIError', 'API request failed: %s - %s', error_code, error_message);
        end
    end

    %% PROCESS RESPONSE
    % Initialize variables to store the data
    dates = [];
    hdd_values = [];
    cdd_values = [];

    % Extract station information for logging
    station_id = '';
    if isfield(response.response, 'stationId')
        station_id = response.response.stationId;
    end

    % Process data for each base temperature
    field_names = fieldnames(response.response.dataSets);

    for i = 1:length(field_names)
        field_name = field_names{i};
        data_set = response.response.dataSets.(field_name);

        if strcmp(data_set.type, 'Failure')
            fprintf('fromDegreeDaysnet WARNING: Failed to get data for %s: %s\n', field_name, data_set.message);
            continue;
        end

        % Convert to MATLAB table with enhanced processing
        if isfield(data_set, 'values') && ~isempty(data_set.values)
            values = data_set.values;

            % Handle different data structures
            if iscell(values)
                % If values is a cell array, convert each cell to a struct
                if ~isempty(values) && all(cellfun(@isstruct, values))
                    % Standardize fields across all structs
                    values_struct = standardize_struct_fields(values);
                    data_table = struct2table(values_struct);
                else
                    fprintf('fromDegreeDaysnet WARNING: Unexpected cell array format in %s\n', field_name);
                    continue;
                end
            elseif isstruct(values)
                % If values is already a struct array, standardize fields
                if length(values) > 1
                    % Multiple structs - standardize and convert
                    values_cell = num2cell(values);
                    values_struct = standardize_struct_fields(values_cell);
                    data_table = struct2table(values_struct);
                else
                    % Single struct - convert directly
                    data_table = struct2table(values);
                end
            else
                fprintf('fromDegreeDaysnet WARNING: Unexpected data format for %s: %s\n', field_name, class(values));
                continue;
            end

            % Convert date strings to datetime
            if ismember('d', data_table.Properties.VariableNames)
                current_dates = datetime(data_table.d, 'InputFormat', 'yyyy-MM-dd');
            else
                fprintf('fromDegreeDaysnet WARNING: No date column found in %s\n', field_name);
                continue;
            end

            % Extract values
            if ismember('v', data_table.Properties.VariableNames)
                current_values = data_table.v;
            else
                fprintf('fromDegreeDaysnet WARNING: No value column found in %s\n', field_name);
                continue;
            end

            % Store data based on type
            if contains(field_name, 'hdd')
                dates = current_dates;
                hdd_values = current_values;
            elseif contains(field_name, 'cdd')
                cdd_values = current_values;
            end
        end
    end

    % Create the output table
    if isempty(dates) || isempty(hdd_values) || isempty(cdd_values)
        error('fromDegreeDaysnet:IncompleteData', ...
            'Failed to retrieve complete HDD and CDD data');
    end

    % Ensure all arrays are the same length
    min_length = min([length(dates), length(hdd_values), length(cdd_values)]);
    dates = dates(1:min_length);
    hdd_values = hdd_values(1:min_length);
    cdd_values = cdd_values(1:min_length);

    % Create column names based on actual base temperatures
    hdd_col_name = sprintf('HDD%d', round(hdd_base));
    cdd_col_name = sprintf('CDD%d', round(cdd_base));

    % Create the final table
    degreedays_data = table(dates, hdd_values, cdd_values, ...
        'VariableNames', {'Date', hdd_col_name, cdd_col_name});

    % Sort by date
    degreedays_data = sortrows(degreedays_data, 'Date');

    fprintf('fromDegreeDaysnet SUCCESS: Retrieved %d records for station %s\n', height(degreedays_data), station_id);
    fprintf('fromDegreeDaysnet: Date range: %s to %s\n', ...
        char(min(degreedays_data.Date)), char(max(degreedays_data.Date)));
    fprintf('fromDegreeDaysnet: Base temperatures - HDD: %g°F, CDD: %g°F\n', hdd_base, cdd_base);

catch ME
    % Enhanced error logging
    fprintf('fromDegreeDaysnet ERROR: %s\n', ME.message);
    if contains(ME.identifier, 'fromDegreeDaysnet:')
        % Re-throw our custom errors as-is
        rethrow(ME);
    else
        % Wrap unexpected errors
        error('fromDegreeDaysnet:UnexpectedError', ...
            'Unexpected error occurred: %s\nPlease contact support with this error message.', ME.message);
    end
end
end

%% Java HTTP fallback implementation
function response_json = send_request_via_java(endpoint, params)

import java.io.* java.net.* java.lang.*

% Create URL encoded parameter string
param_string = '';
param_fields = fieldnames(params);
for j = 1:length(param_fields)
    if j > 1
        param_string = [param_string '&'];
    end
    param_string = [param_string param_fields{j} '=' ...
        char(java.net.URLEncoder.encode(params.(param_fields{j}), 'UTF-8'))];
end

% Create HTTP connection
url = java.net.URL(endpoint);
conn = url.openConnection();
conn.setRequestMethod('POST');
conn.setRequestProperty('Content-Type', 'application/x-www-form-urlencoded');
conn.setDoOutput(true);

% Send request
out = OutputStreamWriter(conn.getOutputStream());
out.write(param_string);
out.close();

% Read response
if conn.getResponseCode() == 200
    in = BufferedReader(InputStreamReader(conn.getInputStream()));
    response_json = '';
    line = in.readLine();
    while ~isempty(line)
        response_json = [response_json char(line)];
        line = in.readLine();
    end
    in.close();
else
    error('HTTP Error: %d', conn.getResponseCode());
end
end

%%  STANDARDIZE_STRUCT_FIELDS - Ensure all structs have the same fields

function standardized_structs = standardize_struct_fields(struct_cell_array)

% This function takes a cell array of structs and adds missing fields
% with default values (NaN for numeric, empty for others) so they can
% be concatenated without field mismatch errors

if isempty(struct_cell_array)
    standardized_structs = struct();
    return;
end

% Get all unique field names across all structs
all_fields = {};
for i = 1:length(struct_cell_array)
    if isstruct(struct_cell_array{i})
        current_fields = fieldnames(struct_cell_array{i});
        all_fields = union(all_fields, current_fields);
    end
end

% Standardize each struct to have all fields
for i = 1:length(struct_cell_array)
    current_struct = struct_cell_array{i};

    % Add missing fields with appropriate default values
    for j = 1:length(all_fields)
        field_name = all_fields{j};
        if ~isfield(current_struct, field_name)
            % Determine default value based on common field patterns
            if strcmp(field_name, 'pe')
                current_struct.(field_name) = 0;  % percentage estimated defaults to 0
            elseif strcmp(field_name, 'v')
                current_struct.(field_name) = NaN;  % value defaults to NaN
            elseif strcmp(field_name, 'd') || strcmp(field_name, 'ld')
                current_struct.(field_name) = '';  % date defaults to empty string
            elseif strcmp(field_name, 'dt')
                current_struct.(field_name) = '';  % datetime defaults to empty string
            else
                current_struct.(field_name) = NaN;  % other numeric fields default to NaN
            end
        end
    end

    struct_cell_array{i} = current_struct;
end %forloop

% Convert cell array to struct array
if isscalar(struct_cell_array)
    standardized_structs = struct_cell_array{1};
else
    standardized_structs = [struct_cell_array{:}];
end %endif

end %function