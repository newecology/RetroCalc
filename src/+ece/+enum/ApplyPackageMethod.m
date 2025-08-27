classdef ApplyPackageMethod < ece.enum.BaseList
    % APPLYPACKAGEMETHOD: Enumeration class for the different methods of
    % applying Packages to a Building.
        
    enumeration
        % Interactive: Each Package builds off previous Package.
        Interactive    ("Interactive")

        % Non-Interactive: Each Package is applied to Base Building.
        NonInteractive ("Non-Interactive")
        
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
