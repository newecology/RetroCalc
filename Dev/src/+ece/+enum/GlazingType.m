classdef GlazingType < ece.enum.BaseList
    % OpaqueSurfaceType Enumeration class for the types of glazing
        
    enumeration
        % Window - vertical 
        Window ("Window")

        % Skylight - window in a roof - not vertical
        Skylight ("Skylight")

        % Curtainwall
        Curtainwall ("Curtainwall")
        
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
