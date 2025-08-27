function [EffCurveHtg,EffCurveClg] = calculateEfficiencies(obj)

% Function to assign distribution and system efficiencies to heating and
% cooling systems.

% Determine heating/cooling system efficiency.
% For each system type there is a default efficiency, and a curve
% for efficiency as a function of outdoor air temperature (OAT). 2 cases.
% 1 The user does not input system efficiency. The software uses the
% default efficiency for that system type, and applies the f(OAT) curve.
% 2 The user inputs system efficiency at one point. The software uses
% that point and adjusts the constant on the f(OAT) curve to match.
% System efficiency curve is efficiency as a function of outdoor air
% temperature (OAT). 5 coefficients for a fourth order polynomial.
% C1*OAT^4 + C2*OAT^3 + C3*OAT^2 + C4*OAT + C5


%%
EffCurveHtg=zeros(1,5);
EffCurveClg=zeros(1,5);
% Load reference tables with the default values.
heatSysData = ece.Reference.HeatSysData;
coolSysData = ece.Reference.CoolSysData;


% Determine default efficiencies for heating systems. This includes
% "heating only" , and "both heating and cooling" systems.
if obj.SystemFunction == "HeatingOnly" || ...
        obj.SystemFunction == "BothHeatingAndCooling"

    dfHeatEff = heatSysData.DefaultHeatingEff(heatSysData.SystemType == ...
        obj.SystemType);
    dfCurve = heatSysData.EffCurveHeating(heatSysData.SystemType == ...
        obj.SystemType, :);

    % If the user has entered a system efficiency value, the curve is
    % adjusted to match. If default values are being used, then the
    % adjustment is zero.
    % The efficiency curve is a constant if the user has entered AFUE, HSPF,
    % or average COP. It is a polynomial function of outdoor air temperature
    %  if the user has entered thermal efficiency or ASHP_COP47F.
    if (obj.HeatEffUnits == "AFUE" || ...
            obj.HeatEffUnits == "averageCOP")
        %curveAdjust = dfHeatEff - obj.HeatEff;
        EffCurveHtg(:) = ...
            [0, 0, 0, 0, obj.HeatEff];

    elseif (obj.HeatEffUnits == "ThermalEfficiency" || ...
            obj.HeatEffUnits == "ASHP_COP47F")
        curveAdjust = dfHeatEff - obj.HeatEff;
        EffCurveHtg(:) = dfCurve;
        EffCurveHtg(5) = dfCurve(5) - curveAdjust;

    end  % if statement for constant or variable curves

end % if statement for heating systems

% Determine default efficiencies for cooling systems.
% This includes "cooling only" , and "both heating and cooling" systems.
if obj.SystemFunction == "CoolingOnly" || ...
        obj.SystemFunction == "BothHeatingAndCooling"

    % Assign short names to the default cooling efficiency variables.
    dfCoolEff = coolSysData.DefaultCoolingEff(coolSysData.SystemType == ...
        obj.SystemType);
    dfCurve = coolSysData.EffCurveCooling(coolSysData.SystemType == ...
        obj.SystemType, :);

    % If the user has entered a system efficiency value, the curve (which
    % could be a constant value) is adjusted to match. If default values
    % are being used, then the adjustment is zero.
    if obj.CoolEffUnits == "IPLV" || ...
            obj.CoolEffUnits == "averageCOP"
        %curveAdjust = dfCoolEff - obj.CoolEff;
        EffCurveClg(:) = ...
            [0, 0, 0, 0, obj.CoolEff];

    elseif obj.CoolEffUnits == "ASHP_COP95F"
        curveAdjust = dfCoolEff - obj.CoolEff;
        EffCurveClg(:) = dfCurve;
        EffCurveClg(5) = dfCurve(5) - curveAdjust;

    end   % if statement for constant or variable curves

end  % if statement for cooling

end   % function statement
