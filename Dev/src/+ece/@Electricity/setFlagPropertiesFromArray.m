function setFlagPropertiesFromArray(e, propArray)
%SETFLAGPROPERTIESFROMARRAY Method to set the Electricity object's flag and
%paramter properties from an input array.
%   To assist in the setting of parameter/property values in Electricity
%   object that is being generated from an EXCEL file, we call this method.
%   The order of the inputs in the propArray matches the order they are
%   obtained from the corresponding excel file (top-down). As a result,
%   this assumes the ordering of properties is as followed (per 3/4/2025):
%     1) NumYearsOfData
%     2) IsBaseload
%     3) IsSpaceHeat
%     4) IsCooling
%     5) IsDHW
%     6) UtilPayerType
%     7) UtilServiceType
%     8) RealEstateType
%     9) BaseAdjustment
%    10) BaseElecAmplitude
%    11) SeasonalAmpDHWUse

%% Arguments
% Ensure inputs are the correct size and type.
arguments
    % e: Self-referential Electricity object.
    e (1,1) ece.Electricity

    % propArray: N-element input vector of doubles that will be mapped to
    % properties in the Electricity object.
    propArray (11,1) double

end %argblock

%% Partition PropArray into Electricity Properties
% Assign elements of array into corresponding values, mapping to enums and
% logicals as needed.

% 1) NumYearsOfData
% Direcly assign double value.
e.NumberOfYears = propArray(1);

% 2) IsBaseLoad
% Convert to logical (0 = false, any other value is true)
e.IsBaseLoad = logical(propArray(2));

% 3) IsSpaceHeat
% Convert to logical (0 = false, any other value is true)
e.IsSpaceHeat = logical(propArray(3));

% 4) IsCooling
% Convert to logical (0 = false, any other value is true)
e.IsCooling = logical(propArray(4));

% 5) IsDHW
% Convert to logical (0 = false, any other value is true)
e.IsDHW = logical(propArray(5));

% 6) PayerType
% Map numeric value to PayerType enumeration member.
e.UtilityPayerType = ...
    ece.enum.UtilityPayerType.fromNumber(propArray(6));

% 7) ServiceType
% Map numeric value to ServiceType enumeration member.
e.UtilityServiceType = ...
    ece.enum.UtilityServiceType.fromNumber(propArray(7));

% 8) RealEstateType
% Map numeric value to RealEstateType enumeration member.
e.RealEstateType = ....
    ece.enum.RealEstateType.fromNumber(propArray(8));

% 9) BaseAdjustment
% Direcly assign double value.
e.ElecBaseAdj = propArray(9);

% 10) BaseElecAmplitude
% Direcly assign double value.
e.BaseElecAmplitude = propArray(10);

% 11) SeasonalAmpDHWUse
% Direcly assign double value.
e.SeasonalAmpDHWUse = propArray(11);

end %function

