classdef ApplianceCategory < ece.enum.BaseList
    % Appliance category enumeration class 
        
    enumeration
      
        Stove ("Stove")

        Dishwasher ("Dishwasher")

        Clotheswasher ("Clotheswasher")

        Dryer ("Dryer")

        Refrigerator ("Refrigerator")

        None ("None")
        
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
