classdef PipeType < ece.enum.BaseList
    % PipeType: Enumeration class for the types of Pipes.
        
    enumeration
        % Bare copper
        CopperBare ("Copper (Bare)")

        % Copper insulated
        CopperInsul ("Copper (Insulated)")

        % Steel bare
        SteelBare ("Steel (Bare)")

        % Steel insulated
        SteelInsul ("Steel (Insulated)")
        
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
