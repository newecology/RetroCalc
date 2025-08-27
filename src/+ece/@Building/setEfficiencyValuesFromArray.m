function setEfficiencyValuesFromArray(b, propArray)
%SETEFFICIENCYVALUESFROMARRAY Method to set the Building object's numeric
%parameter properties from an input array that includes efficiencies.
%   To assist in the setting of parameter/property values in Building
%   object that is being generated from an EXCEL file, we call this method.
%   The order of the inputs in the propArray matches the order they are
%   obtained from the corresponding excel file (top-down). As a result,
%   this assumes the ordering of properties is as followed (per 3/24/2025):
%     1) InUnitGasStoves
%     2) InUnitElectricStoves
%     3) InUnitDishwashers
%     4) InUnitClothesWashers
%     5) InUnitGasClothesDryers
%     6) InUnitElectricClothesDryers
%     7) CommonAreaClothesWasters
%     8) CommonAreaGasClothesDryers
%     9) CommonAreaElectricClothesDryers
%    10) CommercialDishwashers


%% Arguments
% Ensure inputs are the correct size and type.
arguments
    % b: Self-referential Building object.
    b (1,1) ece.Building

    % propArray: N-element input matrix of doubles that will be mapped to
    % properties in the Building object.
    propArray (10,2) double

end %argblock

%% Partition PropArray into Building Properties
% Assign elements of array into correspoding values, mapping to arrays as
% needed.

% 1) InUnitGasStoves
% Place quantity and efficiency in ordered array.
%b.InUnit

% 2) InUnitElectricStoves
% Place quantity and efficiency in ordered array.
%b.InUnit

% 3) InUnitDishwashers
% Place quantity and efficiency in ordered array.
%b.InUnit

% 4) InUnitClothesWashers
% Place quantity and efficiency in ordered array.
%b.InUnit

% 5) InUnitGasClothesDryerss
% Place quantity and efficiency in ordered array.
%b.InUnit

% 6) InUnitElectricClothesDryers
% Place quantity and efficiency in ordered array.
%b.InUnit

% 7) CommonAreaClothesWashers
% Place quantity and efficiency in ordered array.
%b.InUnit

% 8) CommonAreaGasClothesDryers
% Place quantity and efficiency in ordered array.
%b.InUnit

% 9) CommonAreaElectricClothesDryers
% Place quantity and efficiency in ordered array.
%b.InUnit

% 10) CommercialDishwashers
% Place quantity and efficiency in ordered array.
%b.InUnit


end %function

