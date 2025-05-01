classdef CoolCapUnits < ece.enum.BaseList
      enumeration
     
        kBtuPerHour ("kBtu/hr")
        tons ("tons")
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

end % classdef