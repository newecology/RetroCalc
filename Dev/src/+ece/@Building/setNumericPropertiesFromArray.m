function setNumericPropertiesFromArray(b, propArray)
%SETNUMERICPROPERTIESFROMARRAY Method to set the Building object's numeric
%parameter properties from an input array.
%   To assist in the setting of parameter/property values in Building
%   object that is being generated from an EXCEL file, we call this method.
%   The order of the inputs in the propArray matches the order they are
%   obtained from the corresponding excel file (top-down). As a result,
%   this assumes the ordering of properties is as followed (per 3/24/2025):
%     1) GrossArea_ft2
%     2) GrossCondArea_ft2
%     3) IntCondArea_ft2
%     4) PercentAreaCooled
%     5) NumberOfUnits
%     6) NumberOf1BrUnits
%     7) NumberOf2BrUnits
%     8) NumberOf3BrUnits
%     9) NumberOf4BrUnits
%    10) NumberOfOccupants
%    11) NumberOfStories
%    12) YearOfConstruction
%    13) IntVolume_ft3
%    14) AirLeakageRate_cfm50perFt2
%    15) ShieldingClass
%    16) HVACStartTimePeriod1
%    17) HVACEndTimePeriod2
%    18) Heat1SetPt_F
%    19) Heat2SetPt_F
%    20) Cool1SetPt_F
%    21) Cool2SetPt_F
%    22) TargetRHSummer
%    23) TargetRHWinter

%% Arguments
% Ensure inputs are the correct size and type.
arguments
    % b: Self-referential Building object.
    b (1,1) ece.Building

    % propArray: N-element input vector of doubles that will be mapped to
    % properties in the Building object.
    propArray (23,1) double

end %argblock

%% Partition PropArray into Building Properties
% Assign elements of array into correspoding values, mapping to arrays as
% needed.

% 1-3) Building Area Property
% Place all area inputs into a single 1x3 array.
b.BldgArea_ft2 = propArray(1:3);
b.Area_ft2 = propArray(1);

% 4) CoolingAreaPercent
% Set double value directly.
b.BldgPercentCondAreaCooled = propArray(4);

% 5) NumberOfUnits
b.BldgNumberOfUnits = propArray(5);

% 6-9) NumberOfBedroomsUnits
% Place all bedrooms/units counts into single 1x4 array.
b.BldgNumberOfBedrooms = propArray(6:9);

% 10) NumberOfOccupants
b.BldgNumberOfOccupants = propArray(10);

% 11) NumberOfStories
b.BldgNumberOfStories = propArray(11);

% 12) YearOfConstruction
b.BldgYearOfConstruction = propArray(12);

% 13) IntVolume Cubic Feet
b.IntVolume_ft3 = propArray(13);

% 14) AirLeakageRate_cfm50PerFt2
b.AirLeakageRate_cfm50perFt2 = propArray(14);

% 15) ShieldingClass
% Must be between 1 and 5.
b.ShieldingClass = propArray(15);

% 16-17) HVACStartEndTimePeriod1
% Construct 2-element array of start and end periods for HVAC.
b.HVACStartEndTimePeriod1 = propArray(16:17);

% 18-23) HeatCoolSetPoints
% Construct 6-element array of HeatTP1, HeatTP2, CoolTP1, CoolTP2, and then
% CoolRH, HeatRH.
b.HeatCoolSetpoints = propArray(18:23);


end %function

