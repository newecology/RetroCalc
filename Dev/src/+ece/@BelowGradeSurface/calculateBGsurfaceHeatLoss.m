function [BGwallMonthHeatLoss_kBtu, BGfloorMonthHeatLoss_kBtu] = calculateBGsurfaceHeatLoss(obj)
% Calculate heat loss from below grade surfaces, i.e. basement or crawl space.
% Method to compute this within a below grade surface object. 
%   When this method is called, the BG surface object will calculate and update


%% Arguments Block
arguments
    % Obj - Self-referential below grade surface object.
    obj (1,1) ece.BelowGradeSurface
end %argblock

%%
 % Get HeatLossCoeff Value - Method to calculate the
 % HeatLossCoeff values from other properties.
 % The Heat Loss Coefficient is found for each 1 foot vertical wall
 % segment, and for each possible floor segment at various depths
 % initialized to a maximum of 30 foot depth

segmentNum = 1:30;
wallR = zeros(1,30);
floorR = zeros(1,30);
wallTopSegment = 0:29;
wallBottomSegment = 1:30;
wallVerticalSegment = wallBottomSegment - wallTopSegment;
floorDepth = 1:30;

% Calculating wall resistance for each segment
% Calculation carried out for 30 feet below grade. 
wallR = (obj.BaseSlabR + obj.BGwallInsulR) .* 1 .* ...
    (obj.WallInsulDepthBelowGrade_ft >= segmentNum) + ...
    obj.BaseSlabR .* 1 .* (obj.WallInsulDepthBelowGrade_ft < segmentNum);

% Calculating floor resistance for each segment
floorR = ones(1,30) .* (obj.BaseSlabR + obj.BGfloorInsulR);

% Calculating the U for basement wall by segments. Btu/hr-ft2-F
basementWallU = (2 * obj.SoilThermalConductivity ./ (pi * wallVerticalSegment))...
    .* ( log(wallBottomSegment + (2 * obj.SoilThermalConductivity .* wallR / pi)) - log(wallTopSegment...
    + (2 * obj.SoilThermalConductivity .* wallR / pi)) );

% Calculating the U for basement floor by segments. Btu/hr-ft2-F
basementFloorU = (2 * obj.SoilThermalConductivity ./ (pi * obj.BasementMinDimension_ft))...
    .* (log((obj.BasementMinDimension_ft / 2) + (floorDepth) / 2 ...
    + (obj.SoilThermalConductivity .* floorR / pi)) - log((floorDepth / 2) + (obj.SoilThermalConductivity .* floorR / pi)));

% find the middle day of each month for use in the calculation
midDay = [.5:11.5]' / 12 * 365;

% ground surface temperature for each month. °F. formula from Labs et al. 
% Building Foundation Design Handbook, page 81-83. University of 
% Minnesota Underground Space Center. 1988.
% the arrays have 12 rows for the months and 30 columns for the segments
groundSurfaceTemp = obj.GroundMeanAnnualTemp_F - ...
    obj.GroundSurfaceTempAmplitude_F * cos(360/365 ...
    .* (midDay - obj.PhaseConstantForTimeLag_days) * pi/180);
groundSurfaceTempArray = groundSurfaceTemp .* ones(12,30);

%find the heat loss coefficients (HLC) (Btu/hr-ft2) for wall and floor for each segment
%for each month, and the heat loss (kBtu) for each segment
BGwallMonthSegmentHLC = zeros(12,30);
BGWallMonthSegmentHL = zeros(12,30);
BGfloorMonthSegmentHLC = zeros(12,30);
BGfloorMonthSegmentHL = zeros(12,30);
BGwallMonthHeatLoss = zeros(1,12);
BGfloorMonthHeatLoss = zeros(1,12);
daysMonth = [31 28 31 30 31 30 31 31 30 31 30 31];

% basement wall heat loss coefficient values for each segment
% make an array of U values, then an array of HLC's
basementWallUarray = basementWallU .* ones(12,30);
BGwallMonthSegmentHLC = basementWallUarray .* (obj.BasementTemp_F - ...
    groundSurfaceTempArray);

% basement floor heat loss coefficient values for each segment
basementFloorUarray = basementFloorU .* ones(12,30);
BGfloorMonthSegmentHLC = basementFloorUarray .* (obj.BasementTemp_F ...  
    - groundSurfaceTempArray);

% basement wall heat loss in kBtu for each segment, each month
BGWallMonthSegmentHL = BGwallMonthSegmentHLC .* (wallVerticalSegment * ...
    obj.BasementPerimeter_ft) .* daysMonth' * 24 /1000;

% basement floor heat loss in kBtu for each segment, each month
BGfloorMonthSegmentHL = BGfloorMonthSegmentHLC .* obj.BGfloorArea_ft2 ...
    .* daysMonth' * 24 /1000;

% months for which below grade heat loss is counted (October to May in
% Massachusetts) and segments to be summed by depth below grade, all in kBtu
% output is a 12 column row vector for the 12 months
x = ismember([1:12], [1,2,3,4,5,10,11,12])';
y = floorDepth <= obj.BasementDepthBelowGrade_ft;
BGwallMonthHeatLoss_kBtu = sum(BGWallMonthSegmentHL .*x .* y, 2)';
z = floorDepth == obj.BasementDepthBelowGrade_ft;
BGfloorMonthHeatLoss_kBtu = sum(BGfloorMonthSegmentHL .* x .* z, 2)';


end %function

