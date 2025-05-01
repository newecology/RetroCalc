function [BrakeHP, PowerDrawAllFans_kW] =  calculateFanInputPower(obj)
%CALCULATEMOTORPROPERTIES Method to compute Motor property within a Fan 
% object. 
%   When this method is called, the Fan object will calculate and update
%   motor properties (including MotorHP and MotorPowerDraw_kW) based on the
%   selected CalcMethod.

%% Arguments Block
arguments
    % Obj - Self-referential Fan object.
    obj (1,1) ece.Airmovers
end %argblock

%% Determine MotorHP Calculation Pathway
% Check the CalcMethod property of the Fan object to determine how the
% MotorHP property is populated.
BrakeHP = 0;
PowerDrawAllFans_kW = [0,0];
% Utilize switch/case block to handle different calculation methods.
switch (obj.CalcMethod)

    case (ece.enum.CalculationMethod.ComputeMotorPower)
        % -- CalcMethod: Compute Motor Power
        % Calculate the motor brake HP property from other inputs (1 fan, 
        % full speed).
        BrakeHP = obj.DesignCFMperUnit .* ...
            obj.TotalStaticPressure_inch ./ 6354 ./ ...
            obj.FanEfficiency;

        % Calculate Motor Power Draw in kW (all fans of this type, adjusted if 
        % average partial speed with power/flow exponent = 2.0)
        % Two numbers for power draw in time periods 1 and 2.
        PowerDrawAllFans_kW = obj.Quantity .* BrakeHP .* .746 / ...
            obj.MotorEfficiency .* ((obj.AverageSpeed).^2);
        
    case (ece.enum.CalculationMethod.InputMotorPower)
        % -- CalcMethod: Input Motor Power
        % Fan input power for one (MotorPowerDraw_kW) fan was input as part
        % of Fan instantiation. No calculation of input power is required,
        % however the input for one fan must be multiplied by the quantity.

        % Note: It would be good to confirm that fan input power is a non-zero
        % value as a safety check.

        %calculating motor power draw for fans
        PowerDrawAllFans_kW = obj.Quantity .* obj.MotorPowerDraw_kW ...
            .* ((obj.AverageSpeed).^2);  

    otherwise
        % -- CatchAll: Some additional CalcMethod that hasn't been scoped.
        return;

end %switch (obj.CalcMethod)


end %function

