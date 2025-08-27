classdef RecircLoopType < ece.enum.BaseList
    % clothes washer type enumeration class 
        
    enumeration
        CompactInsulated ("Compact (Insulated)")

        Average ("Average")

        LongRunsPoorlyInsulated ("Long Runs (Poorly Insulated)")

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
