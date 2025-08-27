classdef InUnitClothesWasherType < ece.enum.BaseList
    % clothes washer type enumeration class 
        
    enumeration
        FrontLoadingLessThan2_5cubicFeet ("front loading less than 2.5 cubic feet")

        FrontLoadingGreaterThan2_5cubicFeet ("front loading greater than 2.5 cubic feet")

        TopLoading ("top loading")
        
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
