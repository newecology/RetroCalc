function setStringPropertiesFromArray(b, propArray)
%SETSTRINGPROPERTIESFROMARRAY Method to set the Building object's string or
%enumeration parameter properties from an input array of strings.
%   To assist in the setting of parameter/property values in Building
%   object that is being generated from an EXCEL file, we call this method.
%   The order of the inputs in the propArray matches the order they are
%   obtained from the corresponding excel file (top-down). As a result,
%   this assumes the ordering of properties is as followed (per 4/1/2025):
%     1) Name
%     2) BldgPopulationType
%     3) ThermalMass


%% Arguments
% Ensure inputs are the correct size and type.
arguments
    % b: Self-referential Building object.
    b (1,1) ece.Building

    % propArray: N-element input array of strings that will be mapped to
    % properties in the Building object.
    propArray (3,1) string

end %argblock

%% Partition PropArray into Building Properties
% Assign elements of array into correspoding values, mapping to arrays as
% needed.

% 1) Name
% Assign corresponding string property.
b.Name = propArray(1);

% 2) BldgPopulationType
% Map string input to enumeration member for assignment.
b.BldgPopulationType = propArray(2);

% 3) ThermalMass
% Map string input to enumeration member for assignment.
b.ThermalMass = propArray(3);


end %function

