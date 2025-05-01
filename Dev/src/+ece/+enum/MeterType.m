classdef MeterType < ece.enum.BaseList
    %METERTYPE Enumeration class for the types of meters that are used to
    %track a utility's usage.
    %   Utilites can be tracked by different types of meters, which are
    %   captured in this enumeration class.
    
    enumeration
        % Tenant - metered by tenant.
        Tenant ("Tenant")

        % Building - metered by Building.
        Building ("Building")

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
