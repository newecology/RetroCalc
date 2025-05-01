classdef HeatingEfficiencyUnits < ece.enum.BaseList
      enumeration
     
        ThermalEfficiency ("thermal efficiency")
        AFUE ("AFUE - annual fuel utilization efficiency")
        ASHP_COP47F ("air source heat pump COP at 47F")
        ASHP_HSPF ("air source heat pump heating season performance factor")
        averageCOP ("seasonal average COP")
        NA ("not applicable")

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