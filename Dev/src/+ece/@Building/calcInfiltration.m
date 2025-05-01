function [ACHnatHtg, ACHnatClg] = calcInfiltration(obj)
  
  % find building shell area for air leakage calculations
  obj.calculateEnvelopeArea();

  % building air leakage rate in cfm at 50 Pascals  
  AirLeakageRate_cfm50 = obj.AirLeakageRate_cfm50perFt2 * ...
      obj.BuildingEnvelopeArea;
  % ACH50 = Air Changes per hour at 50 pascals
  ACH50 = AirLeakageRate_cfm50 * 60 / obj.IntVolume_ft3;
  % effective leakage area in inches using .055 factor
  effLeakArea = AirLeakageRate_cfm50 * .055;

% .055 is a constant that can be derived from the definition of effective
% leakage area and the flow equation. Both of these are found in ASHRAE 
% Fundamentals Handbook 2021 page 16.16. Reference flow and pressure at 4 Pa
% which is .016 inches water column.
% Value of Cd in leakage area equation is 1.0. Value of n in flow equation
% is .65. Density of air .075 lb/ft3.

  %Getting wind and stacking coefficients for the particular building
  if obj.BldgNumberOfStories > 3
      BldgStories = 3;
  else BldgStories = obj.BldgNumberOfStories;
  end

  stackCoeff = ece.Reference.StackMatrix(BldgStories);
  windCoeff = ece.Reference.ShieldMatrix(obj.ShieldingClass,BldgStories);

  %Getting the setpoints from the hheatcoolsetpoints property array
  htg1Setpt = obj.HeatCoolSetpoints(1);
  htg2Setpt = obj.HeatCoolSetpoints(2);
  clg1Setpt = obj.HeatCoolSetpoints(3);
  clg2Setpt = obj.HeatCoolSetpoints(4);
  
  %find the average temperature difference between inside and outside using 
%Tin - Toutavg for each month for time periods 1 and 2. for heating &
%cooling. same for wind speed
 deltaThtg1 = (htg1Setpt * ones(1,12)) - obj.weatherMonthly(4,1:2:23);
 deltaThtg2 = (htg2Setpt * ones(1,12)) - obj.weatherMonthly(4,2:2:24);
 deltaTclg1 = (clg1Setpt * ones(1,12)) - obj.weatherMonthly(4,1:2:23);
 deltaTclg2 = (clg2Setpt * ones(1,12)) - obj.weatherMonthly(4,2:2:24);
 windSpeed1 = obj.weatherMonthly(6,1:2:23);
 windSpeed2 = obj.weatherMonthly(6,2:2:24);

% Equation from ASHRAE fundamentals for air leakage in cfm as a function of
% temp difference, wind speed, wind, and stack coefficients.
% ASHRAE Fundamentals handbook 2021 16.24
% Average flow in cfm each month and corresponding ACH natural.
 QCFMhtg1 = effLeakArea * sqrt(stackCoeff * abs(deltaThtg1) + windCoeff * windSpeed1.^2);
 ACHnatHtg1 = 60 * QCFMhtg1 / obj.IntVolume_ft3;
 QCFMhtg2 = effLeakArea * sqrt(stackCoeff * abs(deltaThtg2) + windCoeff * windSpeed2.^2);
 ACHnatHtg2 = 60 * QCFMhtg2 / obj.IntVolume_ft3;
 QCFMclg1 = effLeakArea * sqrt(stackCoeff * abs(deltaTclg1) + windCoeff * windSpeed1.^2);
 ACHnatClg1 = 60 * QCFMclg1 / obj.IntVolume_ft3;
 QCFMclg2 = effLeakArea * sqrt(stackCoeff * abs(deltaTclg2) + windCoeff * windSpeed2.^2);
 ACHnatClg2 = 60 * QCFMclg2 / obj.IntVolume_ft3;
 
 %result in a row vector with 24 columns. Jan day, Jan night, Feb day ...
 ACHnatHtg = zeros(1,24);
 ACHnatClg = zeros(1,24);
 ACHnatHtg(1:2:23) = ACHnatHtg1;
 ACHnatHtg(2:2:24) = ACHnatHtg2;
 ACHnatClg(1:2:23) = ACHnatClg1;
 ACHnatClg(2:2:24) = ACHnatClg2;

end 
 