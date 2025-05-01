classdef SystemFunction < ece.enum.BaseList
      enumeration
     
        HeatingOnly ("heating only")
        CoolingOnly ("cooling only")
        BothHeatingAndCooling ("both heating and cooling")

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

end  % class def