classdef ApplianceCategory < ece.enum.BaseList
    % APPLIANCECATEGORY Enumeration class for the different categories that
    % an Appliance object can belong to.
        
    enumeration
        Stove ("Stove");
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

        end %function

    end %methods

end %classdef
