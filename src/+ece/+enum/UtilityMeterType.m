classdef UtilityMeterType < ece.enum.BaseList
    %UTILITYMETERTYPE Enumeration class for the types of different Utility
    %Meter objects that can be made.
    %   This enumeration lists all possible utility subclass types.
    
    enumeration
        % Electricity
        Electricity ("Electricity")

        % Water
        Water ("Water")

        % Gas
        Gas ("Gas")

        % Oil
        Oil ("Oil")

        % Propane
        Propane ("Propane")

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
