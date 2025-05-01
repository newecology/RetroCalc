classdef VentilationType < ece.enum.BaseList
    %listing the different ventilation types
    enumeration
        ExhaustFan ("ExhaustFan")

        SupplyFan ("SupplyFan")
        
        ERV ("ERV")

        AirHandlingUnit ("AirHandlingUnit")

        FanCoilFan ("FanCoilFan")

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

