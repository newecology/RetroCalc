function setDatetimePropertiesFromArray(b, propArray)
%SETDATETIMEPROPERTIESFROMARRAY Method to set the Building object's
%datetime parameter properties from an input array of datetimes.
%   To assist in the setting of parameter/property values in Building
%   object that is being generated from an EXCEL file, we call this method.
%   The order of the inputs in the propArray matches the order they are
%   obtained from the corresponding excel file (top-down). As a result,
%   this assumes the ordering of properties is as followed (per 3/24/2025):
%     1) HeatSeasonStartDate
%     2) HeatSeasonEndDate
%     3) CoolSeasonStartDate
%     4) CoolSeasonEndDate

%% Arguments
% Ensure inputs are the correct size and type.
arguments
    % b: Self-referential Building object.
    b (1,1) ece.Building

    % propArray: N-element input array of dateteimes that will be mapped to
    % properties in the Building object.
    propArray (4,1) string

end %argblock

%% Partition PropArray into Building Properties
% Assign elements of array into correspoding values, mapping to arrays as
% needed.

% 1-4) HeatSeasonStartDate
% Assign corresponding datetime property in order of heating, cooling,
% start and end.
b.HeatCoolSeasonStartEndDates = propArray(1:4);

end %function

