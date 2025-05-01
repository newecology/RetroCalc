classdef WaterHeaterType < ece.enum.BaseList
    % clothes washer type enumeration class 
        
    enumeration
        GasFiredHeaterWithIndirectTank ("gas-fired heater with indirect tank")

        GasFiredTank ("gas-fired tank")

        DemandGas ("demand gas")

        ElectricTank ("electric tank")

        DemandElectric ("demand electric")

        HeatPumpWaterHeater ("heat pump water heater")
       
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
