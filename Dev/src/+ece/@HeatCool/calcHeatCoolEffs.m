function [EffCurveHtg,EffCurveClg]=calcHeatCoolEffs(obj)

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
            
    % Assign short names to the default heating efficiency variables. 
    dfDistEff = heatSysData.defaultDistribEff(heatSysData.SystemType == ...
                    obj.SystemType);
    dfHeatEff = heatSysData.defaultHeatingEff(heatSysData.SystemType == ...
                    obj.SystemType);
    dfEffUnits = heatSysData.effUnits(heatSysData.SystemType == ...
                    obj.SystemType);
    dfCurve = heatSysData.EffCurveHeating(heatSysData.SystemType == ...
                    obj.SystemType, :);

    % Distribution efficiency for heating is either default or user-entered.
            if isnan(obj.DistEffHtg)
                obj.DistEffHtg = dfDistEff;
            end  % if statement
            
    % System efficiency for heating is also either default or user-entered. 
            if isnan(obj.HeatEff)
                obj.HeatEff = dfHeatEff;
                obj.HeatEffUnits = dfEffUnits;
            end  % if statement
            
    % If the user entered value is HSPF, convert to average COP.
           if obj.HeatEffUnits == "ASHP_HSPF"
                    obj.HeatEff = obj.HeatEff / 3.413;
                    obj.HeatEffUnits = "averageCOP";
           end    % if statement to put any Btu/hr per W units into COP
    
    % If the user has entered a system efficiency value, the curve is 
    % adjusted to match. If default values are being used, then the 
    % adjustment is zero.
    % The efficiency curve is a constant if the user has entered AFUE, HSPF,
    % or average COP. It is a polynomial function of outdoor air temperature
    %  if the user has entered thermal efficiency or ASHP_COP47F.
        if obj.HeatEffUnits == "AFUE" || ...
                obj.HeatEffUnits == "averageCOP"
          %curveAdjust = dfHeatEff - obj.HeatEff;
          EffCurveHtg(:) = ...
              [0, 0, 0, 0, obj.HeatEff];

        elseif obj.HeatEffUnits == "ThermalEfficiency" || ...
                obj.HeatEffUnits == "ASHP_COP47F" 
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
    dfDistEff = coolSysData.defaultDistribEff(coolSysData.SystemType == ...
                    obj.SystemType);
    dfCoolEff = coolSysData.defaultCoolingEff(coolSysData.SystemType == ...
                    obj.SystemType);
    dfEffUnits = coolSysData.effUnits(coolSysData.SystemType == ...
                    obj.SystemType);
    dfCurve = coolSysData.EffCurveCooling(coolSysData.SystemType == ...
                    obj.SystemType, :);

    % Distribution efficiency for cooling is either default or user-entered. 
           if isnan(obj.DistEffClg)
               obj.DistEffClg = dfDistEff;
           end  % if statement

    % System efficiency for cooling is also either default or user-entered. 
           if isnan(obj.CoolEff)
                obj.CoolEff = dfHeatEff;
                obj.HeatEffUnits = dfEffUnits;
           end  % if statement

    % Convert any EER values in Btu/hour per Watt to COP. All cooling
    % efficiencies will then be in COP, simplifying later calculations.
    % If the user enters IPLV, it should be in COP units.
           if obj.CoolEffUnits == "EER" || ...
                   obj.CoolEffUnits == "EER2"
                   obj.CoolEff = obj.CoolEff / 3.413;
                   obj.CoolEffUnits = "ASHP_COP95F";
           elseif  obj.CoolEffUnits == "SEER" || ...
                   obj.CoolEffUnits == "SEER2" || ...
                   obj.CoolEffUnits ==  "IEER"
                   obj.CoolEff = obj.CoolEff / 3.413;
                   obj.CoolEffUnits = "averageCOP";
           end  % if statement to convert EER units to COP

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
