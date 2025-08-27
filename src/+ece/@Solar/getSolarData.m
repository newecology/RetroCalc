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

%% Attempt API Call
% Since the output of this method depends on the robustness of the API
% service, a try/catch block is used to trap any API call failures.
try
    % -- Attempt Solar API Call
    % Utilize webread command to extract data.
    pvWattsData = webread(ece.Solar.QueryURL,...
        "api_key",ece.Solar.APIkey,...
        "azimuth",azimuth,...
        "system_capacity",ece.Solar.SystemCapacity,...
        "losses",ece.Solar.Losses,...
        "array_type",ece.Solar.ArrayType,...
        "module_type",ece.Solar.ModuleType,...
        "dataset",ece.Solar.DatasetType,...
        "tilt",tilt,...
        "lat",latitude, "lon",longitude);

catch ME
    % -- Solar API Call Failure
    % Generate a warning message and then output a default empty
    % pvWattsData structure.
    pvWattsData = [];
    statusOK = false;   
    disp("Failure accessing Solar API.");
    assignin("base","ME",ME);

end %try/catch


end %function 

