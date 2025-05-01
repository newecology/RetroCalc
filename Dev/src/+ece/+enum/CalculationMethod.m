classdef CalculationMethod < ece.enum.BaseList
    %CALCULATIONMETHOD Enumeration class for the types of calculations that
    % can be performed on Fans or Pumps.
    %   Depending on the information available for a Fan or Pump, different
    %   calculations can be performed on the data. This enumeration class
    %   enables the separation of calculation methods and provides
    %   flexibility for new ones to be introduced as needed.
    
    enumeration
        % ComputeMotorPower - Calculation method to compute the motor power
        % from inputs.
        ComputeMotorPower ("Calculate Motor Power")
        
        % InputMotorPower - Calculate method to flag that motor power is
        % already input and can be used immediately.
        InputMotorPower ("Input Motor Power")

    end % enumeration

    % Static Methods
    methods (Static)

        function displayNames = getDisplayList()
            % Generates the string array of display names.
            % Note: Useful for populating dropdownlists, etc.

            classPath = mfilename('class');
            enums = enumeration(classPath);
            displayNames = vertcat(enums.DisplayName);

        end

    end %methods

end %classdef
