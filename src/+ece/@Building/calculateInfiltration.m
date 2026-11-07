function [ACHnatHtg, ACHnatClg] = calculateInfiltration(obj)
% CALCULATEINFILTRATION — natural ACH per (month, HVAC period) bucket.
%
% ASHRAE Fundamentals 2021 §16.24:
%   Q_cfm = A_eff * sqrt(stackCoeff * |ΔT| + windCoeff * v^2)
%
% The expression is non-linear in both ΔT and v, so evaluating it with
% monthly-averaged inputs biases the result (Jensen: sqrt is concave, so
% sqrt(mean(f)) >= mean(sqrt(f)); and mean(v)^2 <= mean(v^2)).
% We instead compute Q and ACH hourly from the TMY data, then average by
% (month × period) bucket.

% find building shell area for air leakage calculations
obj.calculateEnvelopeArea();
% building air leakage rate in cfm at 50 Pascals
AirLeakageRate_cfm50 = obj.AirLeakageRate_cfm50perFt2 * obj.BuildingEnvelopeArea;
% effective leakage area in inches using .055 factor
effLeakArea = AirLeakageRate_cfm50 * obj.EffectiveLeakFactor;

% Getting wind and stacking coefficients for the particular building
% MW_MISU: This block of code seems to cap the maximum number of stories in
% a building to 3. Is this done for any particular reason?
bldgStories = min([3, obj.NumberOfStories]);

stackCoeff = ece.Reference.StackMatrix(bldgStories);
windCoeff  = ece.Reference.ShieldMatrix(obj.ShieldingClass, bldgStories);

% Getting the setpoints from the heatcoolsetpoints property array
htg1Setpt = obj.HeatCoolSetpoints(1);
htg2Setpt = obj.HeatCoolSetpoints(2);
clg1Setpt = obj.HeatCoolSetpoints(3);
clg2Setpt = obj.HeatCoolSetpoints(4);

% Hourly weather (populated upstream by calculateDegreeDays): 8760 rows
bwt     = obj.BuildingWeatherTable;
T_hr    = bwt.DryBulb_F;
v_hr    = bwt.wSpeed_mph;
monthHr = bwt.Month;

% Period 1 / Period 2 masks (period 1 = HVACStartEndTimePeriod1 window)
p1Start = obj.HVACStartEndTimePeriod1(1);
p1End   = obj.HVACStartEndTimePeriod1(2);
period1 = bwt.Hour >= p1Start & bwt.Hour < p1End;
period2 = ~period1;

% Hourly ACH for each setpoint variant.
% ACH = 60 * Q_cfm / IntVolume_ft3
invVol   = 60 / obj.IntVolume_ft3;
windTerm = windCoeff * v_hr.^2;
ACHhtg1_hr = effLeakArea * sqrt(stackCoeff * abs(htg1Setpt - T_hr) + windTerm) * invVol;
ACHhtg2_hr = effLeakArea * sqrt(stackCoeff * abs(htg2Setpt - T_hr) + windTerm) * invVol;
ACHclg1_hr = effLeakArea * sqrt(stackCoeff * abs(clg1Setpt - T_hr) + windTerm) * invVol;
ACHclg2_hr = effLeakArea * sqrt(stackCoeff * abs(clg2Setpt - T_hr) + windTerm) * invVol;

% Average hourly ACH over each (month × period) bucket
ACHnatHtg1 = zeros(12, 1);
ACHnatHtg2 = zeros(12, 1);
ACHnatClg1 = zeros(12, 1);
ACHnatClg2 = zeros(12, 1);
for n = 1:12
    p1Mask = (monthHr == n) & period1;
    p2Mask = (monthHr == n) & period2;
    ACHnatHtg1(n) = mean(ACHhtg1_hr(p1Mask));
    ACHnatHtg2(n) = mean(ACHhtg2_hr(p2Mask));
    ACHnatClg1(n) = mean(ACHclg1_hr(p1Mask));
    ACHnatClg2(n) = mean(ACHclg2_hr(p2Mask));
end

% Result in a column vector with 24 rows. Jan day, Jan night, Feb day ...
ACHnatHtg = zeros(24, 1);
ACHnatClg = zeros(24, 1);
ACHnatHtg(1:2:23) = ACHnatHtg1;
ACHnatHtg(2:2:24) = ACHnatHtg2;
ACHnatClg(1:2:23) = ACHnatClg1;
ACHnatClg(2:2:24) = ACHnatClg2;

end
