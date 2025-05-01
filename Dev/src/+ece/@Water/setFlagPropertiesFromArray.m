function setFlagPropertiesFromArray(w, propArray)
%SETFLAGPROPERTIESFROMARRAY Method to set the Water object's flag and
%paramter properties from an input array.
%   To assist in the setting of parameter/property values in Water
%   object that is being generated from an EXCEL file, we call this method.
%   The order of the inputs in the propArray matches the order they are
%   obtained from the corresponding excel file (top-down). As a result,
%   this assumes the ordering of properties is as followed (per 3/4/2025):
%     1) NumYearsOfData
%     2) IsBaseload
%     3) IsIrrigation
%     4) IsCoolingTower
%     5) IsOther
%     6) UtilPayerType

%% Arguments
% Ensure inputs are the correct size and type.
arguments
    % e: Self-referential Water object.
    w (1,1) ece.Water

    % propArray: N-element input vector of doubles that will be mapped to
    % properties in the Water object.
    propArray (6,1) double

end %argblock

%% Partition PropArray into Water Properties
% Assign elements of array into corresponding values, mapping to enums and
% logicals as needed.

% 1) NumYearsOfData
% Direcly assign double value.
w.NumberOfYears = propArray(1);

% 2) IsBaseLoad
% Convert to logical (0 = false, any other value is true)
w.IsBaseLoad = logical(propArray(2));

% 3) IsIrrigation
% Convert to logical (0 = false, any other value is true)
w.IsIrrigation = logical(propArray(3));

% 4) IsCoolingTower
% Convert to logical (0 = false, any other value is true)
w.IsCoolingTower = logical(propArray(4));

% 5) IsOther
% Convert to logical (0 = false, any other value is true)
w.IsOther = logical(propArray(5));

% 6) PayerType
% Map numeric value to PayerType enumeration member.
w.UtilityPayerType = ...
    ece.enum.UtilityPayerType.fromNumber(propArray(6));

end %function

