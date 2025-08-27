classdef ThermalMassType < ece.enum.BaseList
    % OpaqueSurfaceType Enumeration class for the types of opaque surfaces
        
    enumeration
        % Light
        Light ("Light")

        % Medium
        Medium ("Medium")

        % Heavy
        Heavy ("Heavy")

      
        
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
