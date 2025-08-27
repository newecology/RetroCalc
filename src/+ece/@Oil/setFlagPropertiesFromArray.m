function setFlagPropertiesFromArray(oilUtil, propArray)
%SETFLAGPROPERTIESFROMARRAY Method to set the Oil object's flag and
%parameter properties from an input array.
%   To assist in the setting of parameter/property values in Oil
%   object that is being generated from an EXCEL file, we call this method.
%   The order of the inputs in the propArray matches the order they are
%   obtained from the corresponding excel file (top-down). As a result,
%   this assumes the ordering of properties is as followed (per 3/4/2025):
%     1) NumYearsOfData
%     2) IsSpaceHeat
%     3) IsDHW
%     4) IsCooking
%     5) IsClothesDryer
%     6) UtilPayerType
%     7) UtilServiceType
%     8) RealEstateType
%     9) SeasonalAmpDHWUse

%% Arguments
% Ensure inputs are the correct size and type.
arguments
    % oilUtil: Self-referential Oil object.
    oilUtil (1,1) ece.Oil

    % propArray: N-element input vector of doubles that will be mapped to
    % properties in the Oil object.
    propArray (7,1) double

end %argblock

%% Partition PropArray into Oil Properties
% Assign elements of array into corresponding values, mapping to enums and
% logicals as needed.

% 1) NumYearsOfData
% Direcly assign double value.
oilUtil.NumberOfYears = propArray(1);

% 2) IsSpaceHeat
% Convert to logical (0 = false, any other value is true)
oilUtil.IsSpaceHeat = logical(propArray(2));

% 3) IsDHW
% Convert to logical (0 = false, any other value is true)
oilUtil.IsDHW = logical(propArray(3));



% 6) PayerType
% Map numeric value to PayerType enumeration member.
oilUtil.UtilityPayerType = ...
    ece.enum.UtilityPayerType.fromNumber(propArray(4));

% 7) ServiceType
% Map numeric value to ServiceType enumeration member.
oilUtil.UtilityServiceType = ...
    ece.enum.UtilityServiceType.fromNumber(propArray(6));

% 8) RealEstateType
% Map numeric value to RealEstateType enumeration member.
oilUtil.RealEstateType = ....
    ece.enum.RealEstateType.fromNumber(propArray(6));

% 9) SeasonalAmpDHWUse
% Direcly assign double value.
oilUtil.SeasonalAmpDHWUse = propArray(7);

end %function

