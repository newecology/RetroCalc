classdef RefrigeratorVintage < ece.enum.BaseList
    % Enumeration class for the age of refrigerators, in categories
    % as strings
        
    enumeration
         
        Pre1976 ("Pre1976")

        from1976to1986 ("from1976to1986")

        from1987to1989 ("from1987to1989")

        from1990to1992 ("from1990to1992")

        from1993to2000 ("from1993to2000")

        year2001andLater ("year2001andLater")

        from2001to2004EnergyStar ("from2001to2004EnergyStar")

        from2004to2008EnergyStar ("from2004to2008EnergyStar")

        from2008toi2010EnergyStar ("from2008to2010EnergyStar")

        CEEtier3 ("CEEtier3")
        
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
