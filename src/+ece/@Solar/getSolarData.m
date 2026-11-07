function [pvWattsData, statusOK, msg] = getSolarData(azimuth, tilt, latitude, longitude)
%GETSOLARDATA Static method API call to Solar Data web.
%   This method uses webread to make an API call to a service that provides
%   solar data for a set of given inputs.

%% Arguments Block
arguments
    % Azimuth - Angular facing of the queried data.
    azimuth (:,1) double

    % Tilt - Angular tilt of the queried data.
    tilt (:,1) double
       
    latitude (:,1) double
    longitude (:,1) double

end %argblock

%% Initialize Outputs
% Assume that the call will work.
statusOK = true;
msg = "";
%% Resolve API Key
% Prefer a key stored in the environment variable NREL_API_KEY.
% Falls back to the default key baked into the class constan
apiKey = getenv("NREL_API_KEY");
if isempty(apiKey)
    apiKey = ece.Solar.APIkey;
end
%% Attempt API Call — hardcoded URL, then user override, then loud fail
% Fallback chain: (1) baked-in ece.Solar.QueryURL, (2) URL from user config
% at fullfile(prefdir,"retrocalc_endpoints.json") under key "pvwatts_url",
% (3) warn loudly and return empty data.
primaryUrl  = ece.Solar.QueryURL;
overrideUrl = util.getEndpointOverride("pvwatts_url");

pvWattsData = [];   % default if both attempts fail
try
    pvWattsData = doPVWattsCall(primaryUrl, apiKey, azimuth, tilt, latitude, longitude);
    return
catch primaryME
    if strlength(overrideUrl) > 0 && overrideUrl ~= primaryUrl
        try
            pvWattsData = doPVWattsCall(overrideUrl, apiKey, azimuth, tilt, latitude, longitude);
            warning("Solar:PrimaryURLFailed", ...
                "Primary Solar URL %s failed (%s); succeeded with override %s from %s.", ...
                primaryUrl, primaryME.message, overrideUrl, ...
                fullfile(prefdir,"retrocalc_endpoints.json"));
            return
        catch overrideME
            statusOK = false;
            msg = sprintf("Both Solar URLs failed. Primary %s → %s. Override %s → %s.", ...
                primaryUrl, primaryME.message, overrideUrl, overrideME.message);
            warning("Solar:AllURLsFailed", "%s", msg);
            return
        end
    end

    statusOK = false;
    msg = sprintf("Solar URL %s failed (%s). No override configured in %s.", ...
        primaryUrl, primaryME.message, ...
        fullfile(prefdir,"retrocalc_endpoints.json"));
    warning("Solar:URLFailed", "%s", msg);
end

end %function


function data = doPVWattsCall(url, apiKey, azimuth, tilt, latitude, longitude)
data = webread(url, ...
    "api_key",       apiKey, ...
    "azimuth",       azimuth, ...
    "system_capacity", ece.Solar.SystemCapacity, ...
    "losses",        ece.Solar.Losses, ...
    "array_type",    ece.Solar.ArrayType, ...
    "module_type",   ece.Solar.ModuleType, ...
    "dataset",       ece.Solar.DatasetType, ...
    "tilt",          tilt, ...
    "lat",           latitude, ...
    "lon",           longitude);
end

