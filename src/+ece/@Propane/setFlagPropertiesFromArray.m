function setFlagPropertiesFromArray(propaneUtil, propArray)
%SETFLAGPROPERTIESFROMARRAY Method to set the Propnae object's flag and
%parameter properties from an input array.
%   To assist in the setting of parameter/property values in Propnae
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
    % propObj: Self-referential Propnae object.
    propaneUtil (1,1) ece.Propane

    % propArray: N-element input vector of doubles that will be mapped to
    % properties in the Propnae object.
    propArray (10,1) double

end %argblock

%% Partition PropArray into Propnae Properties
% Assign elements of array into corresponding values, mapping to enums and
% logicals as needed.

% 1) NumYearsOfData
% Direcly assign double value.
propaneUtil.NumberOfYears = propArray(1);

% 2) IsSpaceHeat
% Convert to logical (0 = false, any other value is true)
propaneUtil.IsSpaceHeat = logical(propArray(2));

% 3) IsDHW
% Convert to logical (0 = false, any other value is true)
propaneUtil.IsDHW = logical(propArray(3));

% 4) IsCooking
% Convert to logical (0 = false, any other value is true)
propaneUtil.IsCooking = logical(propArray(4));

% 5) IsInUnitClothesDryer
% Convert to logical (0 = false, any other value is true)
propaneUtil.IsInUnitClothesDryer = logical(propArray(5));

% 6) IsCommonAreaClothesDryer
% Convert to logical (0 = false, any other value is true)
propaneUtil.IsCommonAreaClothesDryer = logical(propArray(6));

% 7) PayerType
% Map numeric value to PayerType enumeration member.
propaneUtil.UtilityPayerType = ...
    ece.enum.UtilityPayerType.fromNumber(propArray(7));

% 8) ServiceType
% Map numeric value to ServiceType enumeration member.
propaneUtil.UtilityServiceType = ...
    ece.enum.UtilityServiceType.fromNumber(propArray(8));

% 9) RealEstateType
% Map numeric value to RealEstateType enumeration member.
propaneUtil.RealEstateType = ....
    ece.enum.RealEstateType.fromNumber(propArray(9));

% 10) SeasonalAmpDHWUse
% Direcly assign double value.
propaneUtil.SeasonalAmpDHWUse = propArray(10);

end %function

