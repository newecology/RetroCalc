classdef PipeDiameter < ece.enum.BaseList
    % Pipe diameter Enumeration class. 3/8 to 8 inches.
        
    enumeration
        % 3/8 inch and on up. all in inches.
        .375
        .5
        .75
        1
        1.25
        1.5
        2
        2.5
        3
        4
        5
        6
        8
       
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
