classdef CoolingEfficiencyUnits < ece.enum.BaseList
      enumeration
     
        EER ("energy efficiency ratio - 95Fdb")
        EER2 ("energy efficiency ratio 2 - 95Fdb")
        SEER ("seasonal energy efficiency ratio")
        SEER2 ("seasonal energy efficiency ratio 2")
        IEER ("integrated energy efficiency ratio")
        IPLV ("integrated part load value as COP")
        averageCOP ("seasonal average COP")
        ASHP_COP95F ("COP at 95F drybulb outdoor air temperature")
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