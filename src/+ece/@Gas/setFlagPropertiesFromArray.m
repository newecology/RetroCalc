function setFlagPropertiesFromArray(gasUtil, propArray)
%SETFLAGPROPERTIESFROMARRAY Method to set the Gas object's flag and
%parameter properties from an input array.
%   To assist in the setting of parameter/property values in Gas
%   object that is being generated from an EXCEL file, we call this method.
%   The order of the inputs in the propArray matches the order they are
%   obtained from the corresponding excel file (top-down). As a result,
%   this assumes the ordering of properties is as followed (per 3/4/2025):
%     1) NumYearsOfData
%     2) IsSpaceHeat
%     3) IsDHW
%     4) IsCooking
%     5) IsInUnitClothesDryer
%     6) IsCommonAreaClothesDryer
%     7) UtilPayerType
%     8) UtilServiceType
%     9) RealEstateType
%     10) SeasonalAmpDHWUse

%% Arguments
% Ensure inputs are the correct size and type.
arguments
    % g: Self-referential Gas object.
    gasUtil (1,1) ece.Gas

    % propArray: N-element input vector of doubles that will be mapped to
    % properties in the Gas object.
    propArray (10,1) double

end %argblock

%% Partition PropArray into Gas Properties
% Assign elements of array into corresponding values, mapping to enums and
% logicals as needed.

% 1) NumYearsOfData
% Direcly assign double value.
gasUtil.NumberOfYears = propArray(1);

% 2) IsSpaceHeat
% Convert to logical (0 = false, any other value is true)
gasUtil.IsSpaceHeat = logical(propArray(2));

% 3) IsDHW
% Convert to logical (0 = false, any other value is true)
gasUtil.IsDHW = logical(propArray(3));

% 4) IsCooking
% Convert to logical (0 = false, any other value is true)
gasUtil.IsCooking = logical(propArray(4));

% 5) IsInUnitClothesDryer
% Convert to logical (0 = false, any other value is true)
gasUtil.IsInUnitClothesDryer = logical(propArray(5));

% 6) IsCommonAreaClothesDryer
% Convert to logical (0 = false, any other value is true)
gasUtil.IsCommonAreaClothesDryer = logical(propArray(6));

% 7) PayerType
% Map numeric value to PayerType enumeration member.
gasUtil.UtilityPayerType = ...
    ece.enum.UtilityPayerType.fromNumber(propArray(7));

% 8) ServiceType
% Map numeric value to ServiceType enumeration member.
gasUtil.UtilityServiceType = ...
    ece.enum.UtilityServiceType.fromNumber(propArray(8));

% 9) RealEstateType
% Map numeric value to RealEstateType enumeration member.
gasUtil.RealEstateType = ....
    ece.enum.RealEstateType.fromNumber(propArray(9));

% 10) SeasonalAmpDHWUse
% Direcly assign double value.
gasUtil.SeasonalAmpDHWUse = propArray(10);

end %function

