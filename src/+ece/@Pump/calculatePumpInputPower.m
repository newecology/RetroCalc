function [brakeHP, powerDrawAllpumps_KW] = calculatePumpInputPower(obj)
%CALCULATEMOTORPROPERTIES Method to compute Motor property within a Fan 
% object. 
%   When this method is called, the pump object will calculate and update
%   motor properties (including MotorHP and MotorPowerDraw_kW) based on the
%   selected CalcMethod.

%% Arguments Block
arguments
    % Obj - Self-referential Fan object.
    obj (1,1) ece.Pump
end %argblock

%% Determine MotorHP Calculation Pathway
% Check the CalcMethod property of the pump object to determine how the
% electric power draw of each pump is determined, and then the power ...
% draw of all the pumps combined. 
% Utilize switch/case block to handle different calculation methods.
brakeHP=0;
powerDrawAllpumps_KW=0;
switch (obj.CalcMethod)

    case (ece.enum.CalculationMethod.ComputeMotorPower)
        % -- CalcMethod: Compute Motor Power
        % Calculate the motor brake HP property from other inputs (1 pump, 
        % full speed).
        brakeHP = obj.Flow_gpm .* ...
            obj.HeadPressure_feet ./ 3960 ./ ...
            obj.PumpEfficiency;

        % Calculate Motor Power Draw (all pumps of this type, adjusted if 
        % average partial speed with power/flow exponent = 2.0)
        powerDrawAllpumps_KW = obj.Quantity * brakeHP * 0.746 / ...
            obj.MotorEfficiency * ((obj.AvgSpeed)^2);           

    case (ece.enum.CalculationMethod.InputMotorPower)
        % -- CalcMethod: Input Motor Power
        % pump input power for one (MotorPowerDraw_kW) pump was input as part
        % of pump instantiation. No calculation of input power is required,
        % however the input for one pump must be multiplied by the quantity.

        % Note: It would be good to confirm that pump input power is a non-zero
        % value as a safety check.

        %calculating motor power draw for pumps
        powerDrawAllpumps_KW = obj.Quantity .* obj.MotorPowerDraw_kW; 

    otherwise
        % -- CatchAll: Some additional CalcMethod that hasn't been scoped.
        return;

end %switch (obj.CalcMethod)


end %function

