function url = getEndpointOverride(key)
%GETENDPOINTOVERRIDE Return the user-configured URL override for `key`, or "" if none.
%   Callers use this as the second link in a fallback chain — try the
%   hardcoded URL first, then this on failure, then warn loudly.
%
%   Config file: fullfile(prefdir,"retrocalc_endpoints.json"). Format is a
%   flat JSON object mapping keys to URL strings, e.g.
%     { "pvwatts_url": "https://developer.nlr.gov/api/pvwatts/v8.json" }
%   Missing file / bad JSON / missing key all yield "".
%
%   The config is loaded once per MATLAB session (persistent cache). To
%   pick up changes without restart, call util.getEndpointOverride("__reload__").

persistent cfg cfgLoaded

if key == "__reload__"
    cfgLoaded = false;
    url = "";
    return
end

if isempty(cfgLoaded) || ~cfgLoaded
    cfg = tryLoadConfig();
    cfgLoaded = true;
end

if isfield(cfg, key)
    url = string(cfg.(key));
else
    url = "";
end
end


function cfg = tryLoadConfig()
cfg = struct();
path = fullfile(prefdir, "retrocalc_endpoints.json");
if ~exist(path, "file")
    return
end
try
    cfg = jsondecode(fileread(path));
    fprintf("RetroCalc: loaded endpoint overrides from %s\n", path);
catch ME
    warning("RetroCalc:BadEndpointConfig", ...
        "Could not parse %s (%s). Using built-in URLs only.", ...
        path, ME.message);
    cfg = struct();
end
end
