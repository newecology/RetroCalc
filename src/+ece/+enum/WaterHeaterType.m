classdef WaterHeaterType < ece.enum.BaseList
    % clothes washer type enumeration class 
        
    enumeration
        GasFiredHeaterWithIndirectTank ("Gas-fired Heater with Indirect Tank")

        GasFiredTank ("Gas-fired Tank")

        DemandGas ("Demand Gas")

        ElectricTank ("Electric Tank")

        DemandElectric ("Demand Electric")

        HeatPumpWaterHeater ("Heat Pump Water Heater")
       
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
