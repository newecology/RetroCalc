classdef VentilationType < ece.enum.BaseList
    %listing the different ventilation types
    enumeration
        ExhaustFan ("Exhaust Fan")

        SupplyFan ("Supply Fan")
        
        ERV ("ERV")

        AirHandlingUnit ("Air Handling Unit")

        FanCoilFan ("Fan Coil Fan")

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

