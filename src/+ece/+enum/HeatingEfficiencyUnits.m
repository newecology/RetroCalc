classdef HeatingEfficiencyUnits < ece.enum.BaseList
      enumeration
     
        ThermalEfficiency   ("Thermal Efficiency")
        AFUE                ("AFUE - Annual Fuel Utilization Efficiency")
        ASHP_COP47F         ("Air Source Heat Pump COP at 47F")
        ASHP_HSPF           ("Air Source Heat Pump Heating Season Performance Factor")
        averageCOP          ("Seasonal Average COP")
        NA                  ("N/A")

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